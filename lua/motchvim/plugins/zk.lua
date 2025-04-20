local function new_sync(options, type)
  local zk = require("zk")
  options = vim.tbl_extend("force", { extra = { type = type }, dir = "./syncs/" }, options or {})

  zk.new(options)
end
return {
  {
    "zk-org/zk-nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local zk = require("zk")
      local commands = require("zk.commands")
      zk.setup {
        picker = "fzf_lua",
      }

      commands.add("ZkSync", function(options)
        vim.ui.select({ "mechanics", "mlb-micros", "new" }, { kind = "Sync Type" }, function(item)
          if item == "other" then
            vim.ui.input({ prompt = "Sync type:" }, function(dynamic_item)
              if dynamic_item then
                new_sync(options, dynamic_item)
              else
                vim.notify("[zk] aborting zk sync")
              end
            end)
          else
            new_sync(options, item)
          end
        end)
      end)
    end,
    keys = {
      -- zk new --no-input --extra="type=$1" "$ZK_NOTEBOOK_DIR/syncs/"
      { "<leader>zs", "ZkSync<CR>" },
    },
  },
  {
    "zk-org/neo-tree-zk.nvim",
    dependencies = {
      "zk-org/zk-nvim",
    },
  },
}
