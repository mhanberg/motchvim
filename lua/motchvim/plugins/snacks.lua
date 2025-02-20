return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = {
        notify = true,
        enabled = true,
      },
      statuscolumn = {
        enabled = true,
        folds = { open = true },
      },
    },
  },
}
