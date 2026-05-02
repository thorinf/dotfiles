vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true
vim.opt.termguicolors = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = "a"

vim.opt.showmode = false

vim.opt.clipboard = "unnamedplus"

vim.opt.breakindent = true

vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"

vim.opt.updatetime = 250

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.scrolloff = 10

vim.opt.wrap = true

vim.opt.cmdheight = 0

-- Rounded border on all floating windows (LSP hover, signature, diagnostics, etc).
vim.opt.winborder = "rounded"

vim.api.nvim_create_autocmd("VimResized", {
  pattern = "*",
  command = "wincmd =",
})

-- Global keymaps
vim.keymap.set("n", "<leader>E", "<cmd>Explore<CR>", { desc = "Open netrw (backup)" })

-- Zen mode: hide warnings, only show errors.
vim.keymap.set("n", "<leader>z", function()
  if vim.g.zen_mode_enabled then
    vim.diagnostic.config({ virtual_text = true, underline = true })
    vim.g.zen_mode_enabled = false
  else
    vim.diagnostic.config({
      virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
      underline = { severity = { min = vim.diagnostic.severity.ERROR } },
    })
    vim.g.zen_mode_enabled = true
  end
end, { desc = "Toggle zen mode" })
