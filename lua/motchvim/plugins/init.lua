local theme_file = vim.fn.expand("~/.motchvim-theme")
local theme = vim.trim(table.concat(vim.fn.readfile(theme_file, "\n")))

return {
  { "ruanyl/vim-gh-line", event = { "BufReadPost", "BufNewFile" } },
  { "alvan/vim-closetag", ft = { "html", "liquid", "javascriptreact", "typescriptreact" } },
  { "christoomey/vim-tmux-navigator", event = "VeryLazy" },
  "lewis6991/spaceless.nvim",
  {
    "stevearc/conform.nvim",
    opts = {},
    config = function()
      require("conform").setup {
        formatters = {
          scadformat = {
            command = "scadformat",
          },
        },
        formatters_by_ft = {
          lua = { "stylua" },
          sh = { "shfmt" },
          javascript = { "prettier", "eslint" },
          bash = { "shfmt" },
          zsh = { "shfmt" },
          nix = { "nixpkgs_fmt" },
          -- Conform will run multiple formatters sequentially
          swift = { "swift_format" },
          openscad = { "scadformat" },
        },
      }
    end,
  },
  {
    "AlejandroSuero/freeze-code.nvim",
    opts = {
      copy = true, -- copy after screenshot option
      freeze_config = { -- configuration options for `freeze` command
        output = "freeze.png",
        theme = theme,
      },
    },
    config = function(_, opts)
      require("freeze-code").setup(opts)
    end,
  },
  { "farmergreg/vim-lastplace", event = { "BufReadPre", "BufNewFile" } },
  {
    "tpope/vim-dadbod",
    cmd = { "DB", "DBUI" },
    dependencies = {
      "kristijanhusak/vim-dadbod-completion",
      {
        "kristijanhusak/vim-dadbod-ui",
        init = function()
          vim.g.db_ui_auto_execute_table_helpers = 1
        end,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
  },
  { "tpope/vim-eunuch", event = { "BufReadPost", "BufNewFile" } },
  { "tpope/vim-fugitive", event = "VeryLazy" },
  { "tpope/vim-projectionist", event = { "BufReadPost", "BufNewFile" } },
  { "tpope/vim-repeat", event = { "BufReadPost", "BufNewFile" } },
  { "tpope/vim-rsi", event = "VeryLazy" },
  { "tpope/vim-surround", event = { "BufReadPost", "BufNewFile" } },
  {
    "vim-test/vim-test",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      vim.keymap.set("n", "<leader>n", vim.cmd.TestNearest, { desc = "Run nearest test" })
      vim.keymap.set("n", "<leader>f", vim.cmd.TestFile, { desc = "Run test file" })
      vim.keymap.set("n", "<leader>S", vim.cmd.TestSuite, { desc = "Run test suite" })
      vim.keymap.set("n", "<leader>l", vim.cmd.TestLast, { desc = "Run last test" })

      local vim_notify_notfier = function(cmd, exit)
        if exit == 0 then
          vim.notify("Success: " .. cmd, vim.log.levels.INFO)
        else
          vim.notify("Fail: " .. cmd, vim.log.levels.ERROR)
        end
      end
      -- local terminal_notifier_notfier = function(cmd, exit)
      --   local system = vim.fn.system
      --   if exit == 0 then
      --     print("Success!")
      --     system(string.format([[terminal-notifier -title "Neovim" -subtitle "%s" -message "Success!"]], cmd))
      --   else
      --     print("Failure!")
      --     system(string.format([[terminal-notifier -title "Neovim" -subtitle "%s" -message "Fail!"]], cmd))
      --   end
      -- end

      -- vim.g["test#javascript#jest#executable"] = "bin/test"
      vim.g.motch_term_auto_close = true

      vim.g["test#custom_strategies"] = {
        motch = function(cmd)
          local winnr = vim.fn.winnr()
          require("motchvim.term").open(cmd, winnr, vim_notify_notfier)
        end,
      }
      vim.g["test#strategy"] = "motch"
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      current_line_blame = true,
      current_line_blame_formatter = "   <author>, <committer_time:%R> • <summary>",
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Next hunk" })

        map("n", "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Prev. hunk" })

        -- Actions
        map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "Stage hunk under cursor" })
        map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk under cursor" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk under cursor" })

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk under cursor" })
      end,
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)
    end,
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  { "mg979/vim-visual-multi", branch = "master", event = { "BufReadPost", "BufNewFile" } },
  {
    "folke/lazydev.nvim",
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
  {
    "SmiteshP/nvim-navic",
    -- dir = "~/src/nvim-navic",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local navic = require("nvim-navic")

      navic.setup {
        highlight = true,
        safe_output = true,
        click = true,
      }
    end,
  },
  { "junegunn/vim-easy-align", event = { "BufReadPost", "BufNewFile" } },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
        },
      },
      event_handlers = {
        {
          event = "file_opened",
          handler = function()
            vim.cmd.Neotree("close")
          end,
          id = "close-on-enter",
        },
      },
      sources = {
        -- default sources
        "filesystem",
        "buffers",
        "git_status",
        -- user sources goes here
        "zk",
      },
      -- ...
      zk = {
        follow_current_file = true,
        window = {
          mappings = {
            ["n"] = "change_query",
          },
        },
      },
    },
    config = function(_, opts)
      require("neo-tree").setup(opts)
    end,
    dependencies = {
      "zk-org/neo-tree-zk.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    cmd = {
      "Neotree",
    },
    keys = {
      {
        "-",
        function()
          if require("zk.util").notebook_root(vim.fn.expand("%:p")) ~= nil then
            vim.cmd.Neotree("reveal", "source=zk", "toggle=true", "position=current")
          else
            vim.cmd.Neotree("reveal", "toggle=true", "position=current")
          end
        end,
        mode = "n",
        desc = "Toggle Neotree",
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show { global = false }
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    "MagicDuck/grug-far.nvim",
    config = function()
      require("grug-far").setup {
        prefills = {
          filesFilter = "!.git/",
          flags = "--hidden",
        },
      }
    end,
    cmd = {
      "GrugFar",
    },
    keys = {
      {
        "<space>fr",
        ":GrugFar<cr>",
        desc = "GrugFar",
      },
      {
        "<space>fa",
        function()
          require("grug-far").open { prefills = { paths = vim.fn.expand("%") } }
        end,
        desc = "GrugFar in current file",
      },
    },
  },
}
