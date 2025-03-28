local host = vim.fn.hostname()

local theme_file = vim.fn.expand("~/.motchvim-theme")

_G.motchvim = {
  work = host == "m.hanberg-GQJNV7J4QY",
  theme = vim.trim(table.concat(vim.fn.readfile(theme_file, "\n"))),
}

vim.treesitter.language.register("markdown", "octo")
vim.filetype.add { filename = { Brewfile = "ruby" } }

vim.diagnostic.config {
  virtual_lines = true,
}

vim.cmd.colorscheme(motchvim.theme)
require("motchvim.autocmds")

local opt = vim.opt

vim.env.WALLABY_DRIVER = "chrome"

vim.cmd([[set shortmess+="C,c"]])

vim.g.maplocalleader = ","

opt.timeoutlen = 500

opt.scrolloff = 4
opt.laststatus = 3
opt.winbar = [[%m %t %{%v:lua.require'motchvim.lsp'.navic()%}]]

opt.foldcolumn = "1"
opt.foldlevelstart = 99
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.foldmethod = "expr"
opt.mousemodel = "extend"
opt.fillchars:append {
  fold = " ",
  foldopen = "",
  foldsep = " ",
  foldclose = "",
}
opt.fillchars:append {
  horiz = "━",
  horizup = "┻",
  horizdown = "┳",
  vert = "┃",
  vertleft = "┫",
  vertright = "┣",
  verthoriz = "╋",
}

opt.swapfile = false
opt.colorcolumn = "999"
opt.guifont = "JetBrains Mono"
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.number = true
opt.backupdir = { vim.fn.expand("~/.tmp/backup") }
opt.directory = { vim.fn.expand("~/.tmp/swp/" .. vim.fn.expand("%:p")) }
opt.splitbelow = true
opt.splitright = true
opt.showmode = false
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.undofile = true
opt.undodir = { vim.fn.expand("~/.tmp") }
opt.mouse = "a"
opt.errorbells = false
opt.visualbell = true
-- opt.t_vb = ""
opt.cursorline = true
opt.inccommand = "nosplit"
opt.background = "dark"
opt.autoread = true

opt.title = true

vim.cmd([[command! Q q]])
vim.cmd([[command! Qall qall]])
vim.cmd([[command! QA qall]])
vim.cmd([[command! E e]])
vim.cmd([[command! W w]])
vim.cmd([[command! Wq wq]])

vim.api.nvim_create_user_command("LspLogDelete", function()
  vim.fn.delete(vim.lsp.get_log_path())
end, { desc = "Deletes the LSP log file. Useful for when it gets too big" })
vim.keymap.set("n", "[q", vim.cmd.cprev, { desc = "Go to the previous item in the quickfix list." })
vim.keymap.set("n", "]q", vim.cmd.cnext, { desc = "Go to the next item in the quickfix list." })
vim.keymap.set("n", "<leader><space>", function()
  vim.cmd.set("hls!")
end, { desc = "Toggle search highlight" })

vim.cmd([[tnoremap <esc> <C-\><C-n>]])

vim.g.dispatch_handlers = { "job" }

vim.g.zig_fmt_autosave = 0

vim.g.markdown_syntax_conceal = 0

local LSP = require("motchvim.lsp")

LSP.setup("gh_actions_ls", {})
LSP.setup("lua_ls", {
  settings = {
    Lua = {
      hint = {
        enable = true,
        arrayIndex = "Disable",
      },
      format = {
        enable = false,
      },
      workspace = {
        library = {
          "nvim-test/lua",
          "${3rd}/busted/library",
          "${3rd}/luassert/library",
        },
      },
    },
  },
})
-- LSP.setup("rust_analyzer", {})
LSP.setup("clangd", {})
-- LSP.setup("solargraph", {})
LSP.setup("omnisharp", {})
LSP.setup("ts_ls", {})
-- LSP.setup("vimls", {})
LSP.setup("bashls", {})
-- LSP.setup("sourcekit", {})

LSP.setup("zls", {})
LSP.setup("nixd", {
  settings = {
    nixd = {
      formatting = {
        command = { "alejandra" },
      },
    },
  },
})
-- LSP.setup("nil_ls", {
--   settings = {
--     ["nil"] = {
--       formatting = {
--         command = { "alejandra" },
--       },
--     },
--   },
-- })
LSP.setup("gopls", {})
LSP.setup("jsonls", {})
LSP.setup("cssls", {
  settings = {
    css = {
      lint = {
        unknownAtRules = "ignore",
      },
    },
  },
})

local default_tw_config = LSP.default_config("tailwindcss")
LSP.setup(
  "tailwindcss",
  vim.tbl_deep_extend("force", default_tw_config, {
    -- cmd = vim.lsp.rpc.connect("127.0.0.1", 9000),

    init_options = {
      userLanguages = {
        elixir = "phoenix-heex",
        eruby = "erb",
        heex = "phoenix-heex",
        surface = "phoenix-heex",
      },
    },
    settings = {
      tailwindCSS = {
        validate = true,
        lint = {
          cssConflict = "warning",
          invalidApply = "error",
          invalidScreen = "error",
          invalidVariant = "error",
          invalidConfigPath = "error",
          invalidTailwindDirective = "error",
          recommendedVariantOrder = "warning",
        },
        classAttributes = {
          "class",
          "className",
          "class:list",
          "classList",
          "ngClass",
        },

        experimental = {
          classRegex = {
            [[class:\s*"([^"]*)]],
          },
        },
      },
    },
    filetypes = { "elixir", "eelixir", "html", "liquid", "heex", "surface", "css" },
  })
)
LSP.setup("gopls", {
  settings = {
    gopls = {
      codelenses = { test = true },
    },
  },
})
