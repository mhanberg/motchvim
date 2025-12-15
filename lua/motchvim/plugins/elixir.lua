return {
  {
    "elixir-tools/elixir-tools.nvim",
    version = "*",
    -- dev = true,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local elixir = require("elixir")
      local use_expert = vim.env.USE_EXPERT ~= "0"
      local nextls_opts
      if type(vim.env.NEXTLS_LOCAL) == "string" then
        nextls_opts = {
          enable = not use_expert,
          port = vim.fn.str2nr(vim.env.NEXTLS_LOCAL),
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
          enable = not use_expert,
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

      if use_expert then
        vim.lsp.enable("expert")
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
