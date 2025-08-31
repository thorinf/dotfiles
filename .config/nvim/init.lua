-- leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- providers
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
-- Python provider via uv-managed venv
vim.g.python3_host_prog = os.getenv("HOME") .. "/.venvs/nvim/bin/python"

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- display
vim.wo.number = true           -- line numbers
vim.o.termguicolors = true     -- true color support
vim.o.hlsearch = false         -- no search highlight
vim.wo.signcolumn = "yes"      -- always show sign column

-- indentation
vim.o.tabstop = 2              -- tab width
vim.o.expandtab = true         -- use spaces instead of tabs
vim.o.softtabstop = 2          -- spaces per tab press
vim.o.shiftwidth = 2           -- spaces per indent level
vim.o.breakindent = true       -- wrapped lines maintain indent

-- behavior
vim.o.mouse = "a"              -- enable mouse
vim.o.clipboard = "unnamedplus" -- system clipboard
vim.o.undofile = true          -- persistent undo
vim.o.ignorecase = true        -- case insensitive search
vim.o.smartcase = true         -- unless uppercase used
vim.o.updatetime = 250         -- faster updates
vim.o.timeoutlen = 300         -- faster key sequences
vim.o.completeopt = "menuone,noselect" -- better completion

-- file type detection
vim.cmd("au BufRead,BufNewFile *.templ setfiletype templ")
vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
  pattern = { "*.templ" },
  callback = function()
    vim.api.nvim_buf_set_option(vim.api.nvim_get_current_buf(), "filetype", "templ")
  end,
})

-- mason path setup
local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. (is_windows and ";" or ":") .. vim.env.PATH

-- load plugins
require("lazy").setup("plugins")
