return {
  {
    "elixir-tools/elixir-tools.nvim",
    version = "*",
    -- dev = true,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local elixir = require("elixir")
      local nextls_opts
      if vim.env.NEXTLS_LOCAL == "1" then
        nextls_opts = {
          enable = true,
          port = 9000,
          spitfire = false,
          init_options = {
            experimental = {
              completions = {
                enable = true,
              },
            },
          },
        }
      else
        nextls_opts = {
          enable = true,
          spitfire = false,
          -- cmd = "/home/mitchell/src/next-ls/burrito_out/next_ls_linux_amd64",
          init_options = {
            experimental = {
              completions = {
                enable = true,
              },
            },
          },
        }
      end

      elixir.setup {
        nextls = nextls_opts,
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
