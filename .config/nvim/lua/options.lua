require "nvchad.options"

-- add yours here!

-- Python provider via uv-managed venv
vim.g.python3_host_prog = os.getenv("HOME") .. "/.venvs/nvim/bin/python"

-- Force transparent background
vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NormalNC guibg=NONE ctermbg=NONE
  highlight NormalFloat guibg=NONE ctermbg=NONE
  highlight FloatBorder guibg=NONE ctermbg=NONE
  highlight SignColumn guibg=NONE ctermbg=NONE
  highlight EndOfBuffer guibg=NONE ctermbg=NONE
]])

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
