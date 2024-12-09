-- lua/config/colorscheme.lua

local status, _ = pcall(vim.cmd, "colorscheme nightfly")
if not status then
  vim.notify("Colorscheme 'nightfly' not found! Falling back to default.", vim.log.levels.WARN)
  return
end

