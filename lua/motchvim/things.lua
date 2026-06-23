local things = {}

local function encode_query_param(value)
  return value:gsub("\n", "\r\n"):gsub("([^%w%-_%.~])", function(char)
    return string.format("%%%02X", string.byte(char))
  end)
end

function things.create(opts)
  if opts.range == 0 then
    vim.api.nvim_err_writeln("ThingsCreate requires a visual selection")
    return
  end

  local selection = table.concat(
    vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.visualmode() }),
    "\n"
  )

  if selection == "" then
    vim.api.nvim_err_writeln("ThingsCreate requires a visual selection")
    return
  end

  local source = string.format("%s:%d", vim.fn.expand("%:p"), vim.fn.getpos("'<")[2])
  local notes = selection .. "\n\nSource: " .. source
  local title = selection:match("NOTE:%s*([^\r\n]+)") or selection:match("TODO:%s*([^\r\n]+)")
  local params = {
    "list=" .. encode_query_param("Refactors"),
    "notes=" .. encode_query_param(notes),
  }

  if title ~= nil then
    table.insert(params, 1, "title=" .. encode_query_param(title))
  end

  vim.fn.jobstart({ "open", "things:///add?" .. table.concat(params, "&") }, { detach = true })
end

function things.setup()
  vim.api.nvim_create_user_command("ThingsCreate", things.create, {
    desc = "Create a Things item from the visual selection",
    range = true,
  })
  vim.keymap.set("x", "<leader>tc", ":ThingsCreate<CR>", { desc = "Create a Things item from selection" })
end

return things
