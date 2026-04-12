local cmd
if vim.env.EXPERT_PORT then
  cmd = vim.lsp.rpc.connect("127.0.0.1", vim.fn.str2nr(vim.env.EXPERT_PORT))
elseif vim.env.EXPERT_PATH then
  cmd = { vim.env.EXPERT_PATH, "--stdio" }
else
  cmd = { "expert", "--stdio" }
end

vim.print(cmd)
return {
  cmd = cmd,
  filetypes = { "elixir" },
  root_markers = {
    "mix.lock",
    "mix.exs",
  },
}
