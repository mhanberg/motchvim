return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = "all",
      ignore_install = { "haskell", "phpdoc", "d", "ipkg" },
      highlight = { enable = true },
      indent = { enable = true },
      textobjects = {
        select = {
          enable = true,
          keymaps = {
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["if"] = "@function.inner",
            ["af"] = "@function.outer",
          },
        },
        lsp_interop = {
          enable = true,
          floating_preview_opts = { border = "none" },
          peek_definition_code = {
            ["<leader>df"] = "@function.outer",
            ["<leader>dF"] = "@class.outer",
          },
        },
      },
    },
    config = function(_, opts)
      -- local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      -- parser_config.iex = {
      --   install_info = {
      --     url = "/Users/mitchell/src/tree-sitter-iex", -- local path or git repo
      --     files = { "src/parser.c" }, -- note that some parsers also require src/scanner.c or src/scanner.cc
      --     branch = "main",
      --     generate_requires_npm = false,
      --     requires_generate_from_grammar = false,
      --   },
      -- }
      --
      -- vim.treesitter.language.register("liquid", "liquid")
      -- parser_config.liquid_html = parser_config.html
      -- parser_config.liquid = {
      --   install_info = {
      --     url = "https://github.com/adamazing/tree-sitter-liquid.git", -- local path or git repo
      --     files = { "src/parser.c" }, -- note that some parsers also require src/scanner.c or src/scanner.cc
      --     branch = "main",
      --     generate_requires_npm = false,
      --     requires_generate_from_grammar = true,
      --   },
      -- }
      require("nvim-treesitter.configs").setup(opts)
    end,

    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/playground",
    },
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
