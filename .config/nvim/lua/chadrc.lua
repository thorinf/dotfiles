-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "catppuccin",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

-- Prefer external statusline (lualine) on Neovim 0.9.x to avoid LspProgress usage
-- from nvchad/ui on newer branches.
M.ui = {
  statusline = { enabled = false },
}

return M
