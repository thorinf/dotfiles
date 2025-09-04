-- Use NvChad defaults (cmp capabilities, on_attach, etc.)
local nvlsp = require("nvchad.configs.lspconfig")
nvlsp.defaults()

local lspconfig = require("lspconfig")
local on_attach = nvlsp.on_attach
local capabilities = nvlsp.capabilities

-- Helper: resolve project Python interpreter from .venv if present
local util = require("lspconfig.util")
local function project_python(root)
  local p = root .. "/.venv/bin/python"
  return (vim.fn.executable(p) == 1) and p or "python3"
end

-- Lua
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
        disable = { "different-requires" },
      },
    },
  },
})

-- Rust
lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Tailwind (support templ files)
lspconfig.tailwindcss.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    includeLanguages = {
      templ = "html",
    },
  },
})

-- templ
lspconfig.templ.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- JSON
lspconfig.jsonls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- YAML
lspconfig.yamlls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    yaml = {
      schemaStore = { enable = true },
      validate = true,
    },
  },
})

-- C/C++/CUDA: clangd
local clang_capabilities = vim.tbl_deep_extend("force", capabilities, { offsetEncoding = { "utf-16" } })
lspconfig.clangd.setup({
  on_attach = on_attach,
  capabilities = clang_capabilities,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=never",
    "--query-driver=/usr/bin/clang*,/usr/bin/clang-*,/usr/bin/g++,/usr/bin/gcc,/usr/local/cuda/bin/*",
  },
})

-- Haskell
lspconfig.hls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Python: Ruff LSP (lint/code actions). Formatting is handled by conform.nvim.
lspconfig.ruff.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  -- Use Mason/global ruff-lsp; rely on conform.nvim for formatting on save.
  -- on_new_config = function(new_config, root_dir)
  --   new_config.cmd = { project_python(root_dir), "-m", "ruff", "server" }
  -- end,
})

-- Python: BasedPyright (types) - commented out for less strict ML work
-- local configs = require("lspconfig.configs")
-- if not configs.basedpyright then
--   configs.basedpyright = {
--     default_config = {
--       cmd = { "basedpyright-langserver", "--stdio" },
--       filetypes = { "python" },
--       root_dir = util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git"),
--       settings = {},
--     },
--   }
-- end
--
-- lspconfig.basedpyright.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
--   settings = { python = {} },
--   on_new_config = function(new_config, root_dir)
--     new_config.settings.python.pythonPath = project_python(root_dir)
--   end,
-- })

-- read :h vim.lsp.config for changing options of lsp servers
