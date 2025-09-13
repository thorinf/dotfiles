vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
-- Disable Lua module bytecode cache in this environment to avoid EACCES
-- when writing to XDG_CACHE_HOME during headless syncs.
pcall(function()
  if vim.loader and vim.loader.disable then vim.loader.disable() end
end)
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop

if not (uv and uv.fs_stat(lazypath)) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
pcall(dofile, vim.g.base46_cache .. "defaults")
pcall(dofile, vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)
