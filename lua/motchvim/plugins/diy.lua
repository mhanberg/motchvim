return {
  {
    "mhanberg/output-panel.nvim",
    event = "VeryLazy",
    -- dev = true,
    config = function()
      require("output_panel").setup { max_buffer_size = 5000 }
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
    "mhanberg/workspace-folders.nvim",
    -- dir = "~/src/workspace-folders.nvim",
    lazy = false,
  },
  -- {
  --   "mhanberg/control-panel.nvim",
  --   dir = "~/src/control-panel.nvim",
  --   enable = false,
  --   config = function()
  --     -- local cp = require("control_panel")
  --     -- cp.register {
  --     --   id = "output-panel",
  --     --   title = "Output Panel",
  --     -- }
  --
  --     -- local handler = vim.lsp.handlers["window/logMessage"]
  --
  --     -- vim.lsp.handlers["window/logMessage"] = function(err, result, context)
  --     --   handler(err, result, context)
  --     --   if not err then
  --     --     local client_id = context.client_id
  --     --     local client = vim.lsp.get_client_by_id(client_id)
  --
  --     --     if not cp.panel("output-panel"):has_tab(client.name) then
  --     --       cp.panel("output-panel")
  --     --         :tab { name = client.name, key = tostring(#cp.panel("output-panel"):tabs() + 1) }
  --     --     end
  --
  --     --     cp.panel("output-panel"):append {
  --     --       tab = client.name,
  --     --       text = "[" .. vim.lsp.protocol.MessageType[result.type] .. "] " .. result.message,
  --     --     }
  --     --   end
  --     -- end
  --   end,
  -- },
}
