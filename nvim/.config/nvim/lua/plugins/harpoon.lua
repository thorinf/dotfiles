local harpoon = require("harpoon")
harpoon:setup()

vim.keymap.set("n", "<leader>ha", function()
  harpoon:list():add()
end, { desc = "Harpoon add file" })

vim.keymap.set("n", "<leader>hh", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon quick menu" })

for i = 1, 4 do
  vim.keymap.set("n", "<leader>h" .. i, function()
    harpoon:list():select(i)
  end, { desc = "Harpoon to file " .. i })
end
