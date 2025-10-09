-- accessing built-in netrw, as a backup
vim.keymap.set("n", "<leader>E", "<cmd>Explore<CR>", { desc = "Open netrw (backup)" })

-- zen mode toggle - hide warnings
vim.keymap.set("n", "<leader>z", function()
  local zen_enabled = vim.g.zen_mode_enabled or false

  if zen_enabled then
    -- Restore diagnostics
    vim.diagnostic.config({
      virtual_text = true,
      underline = true,
    })
    vim.g.zen_mode_enabled = false
  else
    -- Disable warnings virtual text and underline
    vim.diagnostic.config({
      virtual_text = {
        severity = { min = vim.diagnostic.severity.ERROR },
      },
      underline = {
        severity = { min = vim.diagnostic.severity.ERROR },
      },
    })
    vim.g.zen_mode_enabled = true
  end
end, { desc = "Toggle zen mode" })
