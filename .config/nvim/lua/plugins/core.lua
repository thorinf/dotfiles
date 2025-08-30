-- essential functionality
return {
  -- completion engine
  require("plugins.core.cmp"),
  
  -- syntax highlighting and parsing
  require("plugins.core.treesitter"),
  
  -- auto-detect indentation
  require("plugins.core.vim-sleuth"),
}