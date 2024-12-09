require("thorinf.plugins-setup")
require('thorinf.core.options')
require("thorinf.core.colorscheme")
require("thorinf.plugins.nvim-tree")
require("thorinf.plugins.nvim-cmp")
require("thorinf.plugins.treesitter")
require("thorinf.plugins.nvim-orgmode")

vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>") -- toggle file explorer
