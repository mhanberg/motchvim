-- Mermaid diagrams on hover.
--
-- Registers a tiny in-process LSP server (a Lua `cmd` function, no external
-- process) that advertises `hoverProvider`. When you hover (K /
-- vim.lsp.buf.hover) inside a fenced ```mermaid block -- in a markdown file or
-- in markdown injected into another language, e.g. an Elixir @moduledoc -- it
-- renders the diagram with `merman-cli --outputFormat=unicode` and returns it
-- as the hover contents. Hovering anywhere else returns nothing, so real LSP
-- hovers are unaffected.
--
-- Optionally (config.image.enabled) the hover shows a PNG drawn with the kitty
-- graphics protocol via snacks.image instead, falling back to unicode when
-- images aren't available.
--
-- Commands: :MermaidEnable, :MermaidDisable, :MermaidToggle, :MermaidRefresh.

local M = {}

M.config = {
  -- merman-cli reads the diagram source from stdin ("-") and writes unicode to stdout.
  cmd = { "merman-cli", "render", "--format", "unicode", "-" },
  -- Filetypes the hover server attaches to. Add more languages whose
  -- doc-comments inject markdown if you want mermaid hover there too.
  filetypes = { "markdown", "elixir" },
  -- Opt-in: render the hover as a PNG drawn with the kitty graphics protocol
  -- (via snacks.image) instead of unicode text. Falls back to the unicode
  -- hover whenever this is off, snacks/the terminal can't show images, or the
  -- PNG render fails -- so leaving it off changes nothing.
  image = {
    enabled = false,
    theme = "dark", -- merman-cli -t (nil to omit)
    background = "transparent", -- merman-cli -b (nil to omit)
    max_width = 100, -- max float size, in terminal cells
    max_height = 40,
  },
}

M.enabled = true

-- source text -> { ok = boolean, lines = string[] }
local cache = {}

local QUERY = [[
  (fenced_code_block
    (info_string (language) @lang)
    (code_fence_content) @content) @block
]]

local query_obj

local function to_lines(s)
  s = (s or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
  local lines = vim.split(s, "\n", { plain = true })
  while #lines > 0 and lines[#lines]:match("^%s*$") do
    table.remove(lines)
  end
  if #lines == 0 then
    lines = { "" }
  end
  return lines
end

-- Detect mermaid blocks with treesitter. Walks the buffer's language tree so it
-- finds markdown whether it's the buffer's own language *or* injected into
-- another language (e.g. an Elixir `@moduledoc`, a Rust doc comment).
-- Returns a list of { first, last, source } where first/last are 0-indexed,
-- inclusive buffer rows covering the whole block (fences included), or nil if
-- treesitter is unavailable for the buffer.
local function detect_treesitter(buf)
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then
    return nil
  end

  if not query_obj then
    local pok, q = pcall(vim.treesitter.query.parse, "markdown", QUERY)
    if not pok then
      return nil
    end
    query_obj = q
  end

  local cap = {}
  for i, name in ipairs(query_obj.captures) do
    cap[name] = i
  end

  local function node(match, name)
    local nodes = match[cap[name]]
    return nodes and nodes[1]
  end

  if not pcall(function()
    parser:parse(true)
  end) then
    return nil
  end

  -- Collect every markdown syntax tree in the buffer (root or injected).
  local roots = {}
  local function visit(lt)
    if lt:lang() == "markdown" then
      for _, tree in ipairs(lt:trees()) do
        roots[#roots + 1] = tree:root()
      end
    end
    for _, child in pairs(lt:children()) do
      visit(child)
    end
  end
  visit(parser)

  local line_count = vim.api.nvim_buf_line_count(buf)
  local blocks = {}
  for _, root in ipairs(roots) do
    for _, match in query_obj:iter_matches(root, buf, 0, -1) do
      local lang = node(match, "lang")
      local content = node(match, "content")
      local block = node(match, "block")
      if lang and content and block and vim.treesitter.get_node_text(lang, buf) == "mermaid" then
        local sr, _, er, ec = block:range()
        local last = (ec == 0) and (er - 1) or er
        last = math.min(last, line_count - 1)
        blocks[#blocks + 1] = {
          first = sr,
          last = last,
          source = vim.treesitter.get_node_text(content, buf),
        }
      end
    end
  end
  return blocks
end

-- Fallback line scanner for when treesitter isn't available.
local function detect_scan(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local blocks = {}
  local i = 1
  while i <= #lines do
    -- opening fence: 3+ backticks or tildes followed by "mermaid"
    local fence = lines[i]:match("^%s*(```+)%s*[Mm]ermaid%s*$") or lines[i]:match("^%s*(~~~+)%s*[Mm]ermaid%s*$")
    if fence then
      local char = fence:sub(1, 1)
      local open = i
      local j = i + 1
      while j <= #lines do
        -- closing fence: 3+ of the same char, nothing else on the line
        local close = lines[j]:match("^%s*([" .. char .. "]+)%s*$")
        if close and #close >= 3 then
          break
        end
        j = j + 1
      end
      local last = math.min(j, #lines)
      blocks[#blocks + 1] = {
        first = open - 1,
        last = last - 1,
        source = table.concat(vim.list_slice(lines, open + 1, last - 1), "\n"),
      }
      i = last + 1
    else
      i = i + 1
    end
  end
  return blocks
end

local function detect_blocks(buf)
  return detect_treesitter(buf) or detect_scan(buf)
end

-- Cache key: a fixed-size hash of the source text plus the render options that
-- affect the output, so editing the diagram *or* changing those options busts
-- the cache (and we don't hold full sources as table keys).
local function cache_key(source, ...)
  local parts = { source }
  for _, opt in ipairs({ ... }) do
    parts[#parts + 1] = tostring(opt)
  end
  return vim.fn.sha256(table.concat(parts, "\0"))
end

-- Render `source` to unicode via merman-cli (cached by source + command).
-- Calls cb(ok, lines); cb may run in a fast event context.
local function render_source(source, cb)
  local key = cache_key(source, table.concat(M.config.cmd, "\0"))
  local entry = cache[key]
  if entry then
    cb(entry.ok, entry.lines)
    return
  end
  vim.system(M.config.cmd, { stdin = source, text = true }, function(res)
    local ok = res.code == 0
    local lines
    if ok then
      lines = to_lines(res.stdout)
    else
      lines = to_lines((res.stderr ~= "" and res.stderr) or res.stdout or "merman-cli failed")
    end
    cache[key] = { ok = ok, lines = lines }
    cb(ok, lines)
  end)
end

-- hash(source + png options) -> { ok = boolean, path = string|nil }
local image_cache = {}

-- Render `source` to a PNG via merman-cli (cached by source + theme +
-- background). The temp files live in Neovim's temp dir, which is wiped on
-- exit. Calls cb(ok, path); cb may run in a fast event context.
local function render_image(source, cb)
  local key = cache_key(source, M.config.image.theme, M.config.image.background)
  local entry = image_cache[key]
  if entry then
    cb(entry.ok, entry.path)
    return
  end
  local path = vim.fn.tempname() .. ".png"
  local cmd = { "merman-cli", "render", "--format", "png" }
  if M.config.image.theme then
    vim.list_extend(cmd, { "-t", M.config.image.theme })
  end
  if M.config.image.background then
    vim.list_extend(cmd, { "-b", M.config.image.background })
  end
  vim.list_extend(cmd, { "-o", path, "-" })
  vim.system(cmd, { stdin = source }, function(res)
    local ok = res.code == 0 and vim.uv.fs_stat(path) ~= nil
    image_cache[key] = { ok = ok, path = ok and path or nil }
    cb(ok, ok and path or nil)
  end)
end

-- Build a hover response for the given position, or nil. Calls cb(result).
local function handle_hover(params, cb)
  if not M.enabled then
    return cb(nil)
  end
  local buf = vim.uri_to_bufnr(params.textDocument.uri)
  if not vim.api.nvim_buf_is_loaded(buf) then
    return cb(nil)
  end

  local line = params.position.line
  local target
  for _, b in ipairs(detect_blocks(buf)) do
    if line >= b.first and line <= b.last then
      target = b
      break
    end
  end
  if not target then
    return cb(nil)
  end

  render_source(target.source, function(ok, lines)
    local value = ok and table.concat(lines, "\n") or ("mermaid render failed:\n" .. table.concat(lines, "\n"))
    -- plaintext so the box-drawing art is shown verbatim (no markdown reflow,
    -- no fence stripping surprises).
    cb({ contents = { kind = "plaintext", value = value } })
  end)
end

-- In-process LSP server: a function cmd that speaks the rpc contract in Lua.
local function make_server()
  return function(dispatchers)
    local closing = false
    local id = 0
    return {
      request = function(method, params, callback)
        id = id + 1
        -- callbacks are scheduled so they never fire before this returns the
        -- request id, and so buffer/window work happens on the main loop.
        if method == "initialize" then
          vim.schedule(function()
            callback(nil, {
              capabilities = { hoverProvider = true },
              serverInfo = { name = "mermaid" },
            })
          end)
        elseif method == "textDocument/hover" then
          handle_hover(params, function(result)
            vim.schedule(function()
              callback(nil, result)
            end)
          end)
        else
          -- shutdown and anything else: empty reply.
          vim.schedule(function()
            callback(nil, nil)
          end)
        end
        return true, id
      end,
      notify = function(method)
        if method == "exit" then
          dispatchers.on_exit(0, 0)
        end
        return true
      end,
      is_closing = function()
        return closing
      end,
      terminate = function()
        closing = true
      end,
    }
  end
end

-- Unicode hover: render the diagram into a float that never wraps (so the
-- box-drawing art stays intact); press the hover key again to step into the
-- float and scroll -- horizontally too, since wrap is off. We use our own
-- float rather than the LSP server's response because noice intercepts LSP
-- hovers and reflows them, ignoring wrap=false.
local function open_unicode_hover(target)
  render_source(target.source, function(ok, lines)
    local content = ok and lines or vim.list_extend({ "mermaid render failed:" }, lines)
    vim.schedule(function()
      -- syntax "" keeps open_floating_preview from running markdown
      -- stylization (which noice overrides), so this stays a plain native float.
      vim.lsp.util.open_floating_preview(content, "", {
        wrap = false,
        focusable = true,
        focus_id = "motchvim-mermaid",
        border = "rounded",
        max_width = math.floor(vim.o.columns * 0.9),
        max_height = math.floor(vim.o.lines * 0.85),
      })
    end)
  end)
end

-- Image hover (opt-in): the diagram as a PNG, drawn with the kitty graphics
-- protocol via snacks.image.
local image_float = {} ---@type { win?: integer, buf?: integer }

local function close_image_float()
  if image_float.buf and vim.api.nvim_buf_is_valid(image_float.buf) then
    pcall(function()
      Snacks.image.placement.clean(image_float.buf)
    end)
  end
  if image_float.win and vim.api.nvim_win_is_valid(image_float.win) then
    pcall(vim.api.nvim_win_close, image_float.win, true)
  end
  image_float = {}
end

local function image_supported()
  local snacks = rawget(_G, "Snacks")
  return snacks
    and snacks.image
    and type(snacks.image.supports_terminal) == "function"
    and snacks.image.supports_terminal()
end

local function open_image_hover(png)
  close_image_float()
  local cfg = M.config.image
  local w, h = cfg.max_width, cfg.max_height
  local ok, size = pcall(function()
    return Snacks.image.util.fit(png, { width = cfg.max_width, height = cfg.max_height })
  end)
  if ok and type(size) == "table" and size.width and size.height then
    w, h = math.max(size.width, 1), math.max(size.height, 1)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(string.rep("\n", h - 1), "\n"))
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = w,
    height = h,
    style = "minimal",
    border = "rounded",
    focusable = false,
    zindex = 50,
  })
  vim.wo[win].wrap = false
  image_float = { win = win, buf = buf }

  pcall(function()
    Snacks.image.buf.attach(buf, { src = png })
  end)

  -- dismiss like a hover: close as soon as the cursor moves
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter", "BufLeave" }, {
    once = true,
    callback = close_image_float,
  })
end

-- Drop-in for a hover keymap. On a mermaid diagram it shows the rendered
-- diagram (unicode by default, or a PNG when image.enabled) in an nvim float.
-- Off a diagram it does a normal hover. Map it with e.g.
--   vim.keymap.set("n", "K", require("motchvim.mermaid").hover)
function M.hover()
  local buf = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local target
  if M.enabled then
    for _, b in ipairs(detect_blocks(buf)) do
      if line >= b.first and line <= b.last then
        target = b
        break
      end
    end
  end

  if not target then
    return vim.lsp.buf.hover({ border = "rounded" })
  end

  if M.config.image.enabled then
    render_image(target.source, function(ok, png)
      vim.schedule(function()
        if ok and png and image_supported() then
          open_image_hover(png)
        else
          open_unicode_hover(target) -- PNG failed or terminal can't show images
        end
      end)
    end)
    return
  end

  open_unicode_hover(target)
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  if vim.fn.executable(M.config.cmd[1]) ~= 1 then
    return
  end

  vim.lsp.config("mermaid", {
    cmd = make_server(),
    filetypes = M.config.filetypes,
    -- A constant root_dir means one shared client serves every buffer.
    root_dir = vim.fn.stdpath("data"),
  })
  vim.lsp.enable("mermaid")

  local function set_enabled(value)
    M.enabled = value
  end

  vim.api.nvim_create_user_command("MermaidEnable", function()
    set_enabled(true)
  end, { desc = "Enable mermaid diagram hover" })

  vim.api.nvim_create_user_command("MermaidDisable", function()
    set_enabled(false)
  end, { desc = "Disable mermaid diagram hover" })

  vim.api.nvim_create_user_command("MermaidToggle", function()
    set_enabled(not M.enabled)
  end, { desc = "Toggle mermaid diagram hover" })

  vim.api.nvim_create_user_command("MermaidRefresh", function()
    cache = {}
    image_cache = {}
  end, { desc = "Clear the mermaid render cache" })
end

return M
