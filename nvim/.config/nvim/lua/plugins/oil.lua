return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    opts = {
      default_file_explorer = false,
    },
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
    },
  },
}
