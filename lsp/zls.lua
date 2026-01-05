return {
  cmd = { "zls" },
  filetypes = { "zig", "zir" },
  root_markers = { "build.zig", "build.zon.zig" },
  settings = {
    zls = {
      enable_build_on_save = true,
      build_on_save_args = { "check", "test" },
    },
  },
}
