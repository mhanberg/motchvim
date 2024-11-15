return {
  {
    "iguanacucumber/magazine.nvim",
    name = "nvim-cmp", -- Otherwise highlighting gets messed up
    lazy = true,
    event = "InsertEnter",
    init = function()
      vim.opt.completeopt = { "menu", "menuone", "noselect" }
    end,
    config = function()
      local cmp = require("cmp")

      cmp.setup {
        snippet = {
          expand = function(args)
            -- For `vsnip` user.
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert {
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<C-y>"] = cmp.mapping.confirm { select = true },
        },
        sources = {
          { name = "lazydev" },
          { name = "nvim_lsp" },
          { name = "vsnip" },
          { name = "vim-dadbod-completion" },
          { name = "spell", keyword_length = 5 },
          -- { name = "rg", keyword_length = 3 },
          -- { name = "buffer", keyword_length = 3 },
          -- { name = "emoji" },
          { name = "path" },
          { name = "git" },
        },
        formatting = {
          format = require("lspkind").cmp_format {
            with_text = true,
            menu = {
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              luasnip = "[LuaSnip]",
              -- emoji = "[Emoji]",
              spell = "[Spell]",
              path = "[Path]",
              cmdline = "[Cmd]",
            },
          },
        },
      }

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline", keyword_length = 2 } }),
      })
    end,
    dependencies = {
      { "iguanacucumber/mag-cmdline", name = "cmp-cmdline", event = { "CmdlineEnter" } },
      "f3fora/cmp-spell",
      { "iguanacucumber/mag-nvim-lsp", name = "cmp-nvim-lsp", opts = {} },
      "https://codeberg.org/FelipeLema/cmp-async-path",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",

      "onsails/lspkind-nvim",
      {
        "petertriho/cmp-git",
        config = function()
          require("cmp_git").setup()
        end,
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
  },
}
