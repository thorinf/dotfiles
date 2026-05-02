return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gf", ":DiffviewOpen origin/main<CR>", desc = "Diff vs main" },
    { "<leader>gq", ":DiffviewClose<CR>", desc = "Close diff" },
    { "<leader>gl", ":DiffviewToggleFiles<CR>", desc = "Toggle diffview file list" },
  },
  opts = {
    enhanced_diff_hl = true,
    file_panel = {
      listing_style = "tree",
      tree_options = { flatten_dirs = true, folder_statuses = "only_folded" },
      win_config = {
        type = "float",
        position = "center",
        relative = "editor",
        width = 60,
        height = 25,
        border = "rounded",
      },
    },
    hooks = {
      view_opened = function()
        vim.cmd("DiffviewToggleFiles")
      end,
      diff_buf_win_enter = function(_, win)
        vim.wo[win].winbar = ""
      end,
    },
  },
}
