return {
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
}
