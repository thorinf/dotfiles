return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({
        transparent = true,
        italic_comments = true,
        hide_fillchars = false,
        borderless_pickers = false,
        terminal_colors = true,
        cache = false,

        extensions = {
          telescope = true,
          notify = true,
          whichkey = true,
          treesitter = true,
        },
      })

      vim.cmd("colorscheme cyberdream")
    end,
  },
}
