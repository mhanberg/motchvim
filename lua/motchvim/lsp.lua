M = {}

local has_run = {}

local signs = {
  Error = "✘", -- x000f015a
  Warn = "󰀪", -- x000f002a
  Info = "󰋽", -- x000f02fd
  Hint = "󰌶", -- x000f0336
}

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

M.navic = function()
  if package.loaded["nvim-navic"] then
    local navic = require("nvim-navic")
    local loc = navic.get_location()
    if loc and #loc > 0 then
      return "%#NavicSeparator#> " .. navic.get_location()
    else
      return ""
    end
  else
    return ""
  end
end

local levels = {
  "ERROR",
  "WARN",
  "INFO",
  "DEBUG",
  [0] = "TRACE",
}

vim.lsp.handlers["window/showMessage"] = function(_, result)
  -- if require("vim.lsp.log").should_log(convert_lsp_log_level_to_neovim_log_level(result.type)) then
  -- vim.print(result.message)
  vim.notify(result.message, vim.log.levels[levels[result.type]])
  -- end
end

M.default_config = function(name)
  return require("lspconfig.configs." .. name).default_config
end

vim.lsp.set_log_level(3)

return M
