return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    branch = "main",
    build = ":TSUpdate",
    config = function(_, opts)
      require("nvim-treesitter").install { "stable" }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = true,
    enabled = true,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("treesitter-context").setup {
        max_lines = 3,
      }
    end,
  },
  { "IndianBoy42/tree-sitter-just" },
}
