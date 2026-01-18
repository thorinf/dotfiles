return {
  "mwcm/vim-tidal",
  ft = "tidal",
  init = function()
    vim.g.tidal_target = "terminal"
    vim.g.tidal_boot_fallback = vim.fn.expand("~/.config/tidal/BootTidal.hs")
    vim.g.tidal_split_direction = "right"
  end,
}
