return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gf", ":DiffviewOpen origin/main<CR>", desc = "Diff vs main" },
    { "<leader>gq", ":DiffviewClose<CR>", desc = "Close diff" },
  },
  opts = {
    enhanced_diff_hl = true,
    file_panel = { listing_style = "list" },
  },
}
