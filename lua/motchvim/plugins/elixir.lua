return {
  {
    "elixir-tools/elixir-tools.nvim",
    version = "*",
    -- dev = true,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local elixir = require("elixir")

      elixir.setup {
        nextls = { enable = false },
        credo = { enable = false },
        elixirls = { enable = false },
      }
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "mhanberg/workspace-folders.nvim",
    },
  },
}
