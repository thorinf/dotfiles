require "nvchad.options"

-- add yours here!

-- Enable relative line numbers
vim.wo.relativenumber = true

-- Python provider: prefer ~/.venvs/nvim/bin/python if it exists; else fallback to system python3
do
  local venv_python = os.getenv("HOME") .. "/.venvs/nvim/bin/python"
  if vim.fn.executable(venv_python) == 1 then
    vim.g.python3_host_prog = venv_python
  else
    vim.g.python3_host_prog = "python3"
  end
end

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
