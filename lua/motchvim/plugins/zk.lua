return {
  {
    "zk-org/zk-nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("zk").setup {
        picker = "fzf_lua",
      }
    end,
  },
  {
    "zk-org/neo-tree-zk.nvim",
    dependencies = {
      "zk-org/zk-nvim",
    },
  },
}
