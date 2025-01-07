return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      statuscolumn = {
        enabled = true,
        folds = { open = true },
      },
    },
  },
}
