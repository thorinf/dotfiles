-- user interface and appearance
return {
  -- colorschemes
  require("plugins.ui.colorscheme"),
  
  -- statusline
  require("plugins.ui.lualine"),
  
  -- file icons
  require("plugins.ui.icons"),
  
  -- keybinding helper
  require("plugins.ui.which-key"),
}