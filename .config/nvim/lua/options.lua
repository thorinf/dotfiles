require "nvchad.options"

-- add yours here!

-- Force transparent background
vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NormalNC guibg=NONE ctermbg=NONE
  highlight SignColumn guibg=NONE ctermbg=NONE
  highlight EndOfBuffer guibg=NONE ctermbg=NONE
]])

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
