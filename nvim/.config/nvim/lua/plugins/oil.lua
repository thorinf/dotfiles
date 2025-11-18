function _G.get_oil_winbar()
  -- statusline_winid exists only while the winbar/statusline is evaluated; fall back to the active win
  local winid = vim.g.statusline_winid or vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local dir = require("oil").get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ":~")
  end
  return vim.api.nvim_buf_get_name(bufnr)
end

return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    opts = {
      default_file_explorer = false,
      win_options = {
        winbar = "%!v:lua.get_oil_winbar()",
      },
    },
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
    },
  },
}
