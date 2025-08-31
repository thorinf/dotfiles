require "nvchad.autocmds"

-- Filetype detection for templ
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.templ",
  callback = function()
    vim.opt_local.filetype = "templ"
  end,
})
