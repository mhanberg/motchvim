vim.cmd([[setlocal spell]])
vim.cmd([[setlocal linebreak]])
if require("zk.util").notebook_root(vim.fn.expand("%:p")) ~= nil then
  local zk = require("zk")
  local opts = function(tbl)
    return vim.tbl_extend("keep", { buffer = 0, silent = true }, tbl)
  end

  vim.keymap.set("n", "<space>zf", "<Cmd>ZkNotes { sort = {'modified'} }<CR>", opts { desc = "Find notes" })
  vim.keymap.set("n", "<space>zt", vim.cmd.ZkTags, opts { desc = "Find tags" })
  vim.keymap.set("n", "<space>zl", vim.cmd.ZkLinks, opts { desc = "Find links in note" })
  vim.keymap.set("n", "<space>zb", vim.cmd.ZkBacklinks, opts { desc = "Find backlinks in note" })
  vim.keymap.set("n", "<space>zd", function()
    vim.cmd.ZkNew { group = "daily", dir = "journal/daily" }
  end, opts { desc = "New Journal Entry" })
  vim.keymap.set(
    "v",
    "<space>zn",
    ":'<,'>ZkNewFromTitleSelection { dir = vim.fn.expand('%:p:h') }<CR>",
    opts { desc = "Create and link note from selection" }
  )

  -- if vim.fn.expand("%:h") == "dnd" then
  --   require("motchvim.dnd")
  --   vim.keymap.set(
  --     "n",
  --     "<A-j>",
  --     [[:lua motchvim.dnd.move_to("previous")<cr>]],
  --     opts { desc = "Previous D&D note" }
  --   )
  --   vim.keymap.set("n", "<A-k>", [[:lua motchvim.dnd.move_to("next")<cr>]], opts { desc = "Next D&D note" })
  -- end
end
