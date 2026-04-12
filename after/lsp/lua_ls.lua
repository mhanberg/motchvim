return {
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
}
