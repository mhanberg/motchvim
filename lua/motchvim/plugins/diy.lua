return {
  {
    "mhanberg/output-panel.nvim",
    enable = false,
    event = "VeryLazy",
    -- dev = true,
    config = function()
      require("output_panel").setup()
    end,
    keys = {
      {
        "<leader>o",
        vim.cmd.OutputPanel,
        mode = "n",
        desc = "Toggle the output panel",
      },
    },
  },
  {
    "mhanberg/zk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function(_, opts)
      require("zk").setup(opts)
    end,
    opts = {
      filetypes = { "markdown", "liquid" },
      on_attach = function(_, bufnr)
        local opts = function(tbl)
          return vim.tbl_extend("keep", { buffer = bufnr, silent = true }, tbl)
        end

        vim.keymap.set("n", "<space>zf", vim.cmd.Notes, opts { desc = "Find notes" })
        vim.keymap.set("n", "<space>zt", vim.cmd.Tags, opts { desc = "Find tags" })
        vim.keymap.set("n", "<space>zl", vim.cmd.Links, opts { desc = "Find links in note" })
        vim.keymap.set("n", "<space>zb", vim.cmd.Backlinks, opts { desc = "Find backlinks in note" })
        vim.keymap.set(
          "n",
          "<space>zd",
          [[:lua require("zk").new({group = "daily", dir = "journal/daily"})<cr>]],
          opts { desc = "New Journal Entry" }
        )
        vim.keymap.set("v", "<space>zn", function()
          vim.lsp.buf.code_action {
            apply = true,
            filter = function(ca)
              return ca.title == [[New note in top directory]]
            end,
          }
        end, opts { desc = "Create and link note from selection" })

        if vim.fn.expand("%:h") == "dnd" then
          require("motchvim.dnd")
          vim.keymap.set(
            "n",
            "<A-j>",
            [[:lua motchvim.dnd.move_to("previous")<cr>]],
            opts { desc = "Previous D&D note" }
          )
          vim.keymap.set(
            "n",
            "<A-k>",
            [[:lua motchvim.dnd.move_to("next")<cr>]],
            opts { desc = "Next D&D note" }
          )
        end
      end,
    },
    dependencies = {
      "ibhagwan/fzf-lua",
      "neovim/nvim-lspconfig",
    },
  },
  {
    "mhanberg/workspace-folder.nvim",
    dir = "~/src/workspace-folders.nvim",
    lazy = false,
  },
  {
    dir = "~/src/control-panel.nvim",
    enable = false,
    config = function()
      -- local cp = require("control_panel")
      -- cp.register {
      --   id = "output-panel",
      --   title = "Output Panel",
      -- }

      -- local handler = vim.lsp.handlers["window/logMessage"]

      -- vim.lsp.handlers["window/logMessage"] = function(err, result, context)
      --   handler(err, result, context)
      --   if not err then
      --     local client_id = context.client_id
      --     local client = vim.lsp.get_client_by_id(client_id)

      --     if not cp.panel("output-panel"):has_tab(client.name) then
      --       cp.panel("output-panel")
      --         :tab { name = client.name, key = tostring(#cp.panel("output-panel"):tabs() + 1) }
      --     end

      --     cp.panel("output-panel"):append {
      --       tab = client.name,
      --       text = "[" .. vim.lsp.protocol.MessageType[result.type] .. "] " .. result.message,
      --     }
      --   end
      -- end
    end,
  },
}
