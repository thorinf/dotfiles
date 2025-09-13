return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "NvimTree" } },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    event = 'BufWritePre',
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  -- Mason core (no deprecated auto-install flags)
  { "williamboman/mason.nvim" },

  -- Install/manage external tools (CLIs & LSP servers) explicitly
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- Python
        "ruff",                 -- Native Ruff server + CLI
        "pyright",
        -- Lua
        "lua-language-server",
        "stylua",               -- Lua formatter
        -- Web/UX
        "tailwindcss-language-server",
        "json-lsp",
        "yaml-language-server",
        -- Systems
        "clangd",
        -- Others
        "rust-analyzer",
        "haskell-language-server",
        "templ",
      },
      run_on_start = true,
      start_delay = 0,
      auto_update = false,
    },
  },

  -- Keep mason-lspconfig for registry/metadata; no deprecated options
  { "williamboman/mason-lspconfig.nvim", dependencies = { "mason.nvim" } },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-lspconfig.nvim" },
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = require "configs.nvimtree",
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
