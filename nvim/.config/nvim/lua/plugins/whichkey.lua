require("which-key").setup({
  spec = {
    { "<leader>c", group = "Code" },
    { "<leader>f", group = "Find" },
    { "<leader>g", group = "Git" },
    { "<leader>h", group = "Harpoon" },
    { "<leader>l", group = "LSP" },
  },
  show_help = true,
  show_keys = true,
})

vim.keymap.set("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "Buffer Local Keymaps" })
