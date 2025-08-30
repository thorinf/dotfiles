return {
  ensure_installed = {
    "lua-language-server",
    "rust-analyzer",
    "rustfmt",
    "stylua",
    -- python
    "basedpyright",
    "ruff",
    -- c/c++/cuda
    "clangd",
    "clang-format",
    -- haskell (disabled: install system-wide instead)
  },
}
