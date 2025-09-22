return {
  {
    "saghen/blink.cmp",
    -- optional: provides snippets for the snippet source
    dependencies = {
      "rafamadriz/friendly-snippets",
      "Kaiser-Yang/blink-cmp-git",
    },

    -- use a release tag to download pre-built binaries
    version = "v1.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = "default" },
      fuzzy = {
        frecency = { enabled = false },
        use_proximity = false,
      },
      cmdline = {
        enabled = true,
        completion = {
          menu = {
            auto_show = true,
          },
          ghost_text = {
            enabled = true,
          },
        },
      },
      completion = {
        list = {
          selection = { auto_insert = true },
        },
        menu = {
          border = "rounded",
        },
        accept = { auto_brackets = { enabled = false } },
        documentation = {
          window = {
            border = "rounded",
          },
          auto_show = true,
          auto_show_delay_ms = 0,
        },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      signature = { enabled = true },
      sources = {
        default = { "git", "lsp", "path" },
        min_keyword_length = function(ctx)
          if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then
            return 2
          end
          return 0
        end,
        providers = {
          git = {
            module = "blink-cmp-git",
            name = "Git",
            opts = {
              -- options for the blink-cmp-git
            },
          },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
  -- {
  --   "iguanacucumber/magazine.nvim",
  --   name = "nvim-cmp", -- Otherwise highlighting gets messed up
  --   lazy = true,
  --   event = "InsertEnter",
  --   init = function()
  --     vim.opt.completeopt = { "menu", "menuone", "noselect" }
  --   end,
  --   config = function()
  --     local cmp = require("cmp")
  --
  --     cmp.setup {
  --       snippet = {
  --         expand = function(args)
  --           -- For `vsnip` user.
  --           vim.fn["vsnip#anonymous"](args.body)
  --         end,
  --       },
  --       window = {
  --         completion = cmp.config.window.bordered(),
  --         documentation = cmp.config.window.bordered(),
  --       },
  --       mapping = cmp.mapping.preset.insert {
  --         ["<C-b>"] = cmp.mapping.scroll_docs(-4),
  --         ["<C-f>"] = cmp.mapping.scroll_docs(4),
  --         ["<C-Space>"] = cmp.mapping.complete(),
  --         ["<C-e>"] = cmp.mapping.close(),
  --         ["<C-y>"] = cmp.mapping.confirm { select = true },
  --       },
  --       sources = {
  --         { name = "lazydev" },
  --         { name = "nvim_lsp" },
  --         { name = "vsnip" },
  --         { name = "vim-dadbod-completion" },
  --         { name = "spell", keyword_length = 5 },
  --         -- { name = "rg", keyword_length = 3 },
  --         -- { name = "buffer", keyword_length = 3 },
  --         -- { name = "emoji" },
  --         { name = "path" },
  --         { name = "git" },
  --       },
  --       formatting = {
  --         format = require("lspkind").cmp_format {
  --           with_text = true,
  --           menu = {
  --             buffer = "[Buffer]",
  --             nvim_lsp = "[LSP]",
  --             luasnip = "[LuaSnip]",
  --             -- emoji = "[Emoji]",
  --             spell = "[Spell]",
  --             path = "[Path]",
  --             cmdline = "[Cmd]",
  --           },
  --         },
  --       },
  --     }
  --
  --     cmp.setup.cmdline(":", {
  --       mapping = cmp.mapping.preset.cmdline(),
  --       sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline", keyword_length = 2 } }),
  --     })
  --   end,
  --   dependencies = {
  --     { "iguanacucumber/mag-cmdline", name = "cmp-cmdline", event = { "CmdlineEnter" } },
  --     "f3fora/cmp-spell",
  --     { "iguanacucumber/mag-nvim-lsp", name = "cmp-nvim-lsp", opts = {} },
  --     "https://codeberg.org/FelipeLema/cmp-async-path",
  --     "hrsh7th/cmp-vsnip",
  --     "hrsh7th/vim-vsnip",
  --
  --     "onsails/lspkind-nvim",
  --     {
  --       "petertriho/cmp-git",
  --       config = function()
  --         require("cmp_git").setup()
  --       end,
  --       dependencies = { "nvim-lua/plenary.nvim" },
  --     },
  --   },
  -- },
}
