local cmd = vim.env.EXPERT_PATH or "expert"
return {
  cmd = { cmd, "--stdio" },
  filetypes = { "elixir" },
  root_markers = {
    "mix.lock",
    "mix.exs",
  },
}
