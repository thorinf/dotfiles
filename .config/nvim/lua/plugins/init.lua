-- core functionality
require("plugins.core")

-- lsp and language support  
require("plugins.lsp")

-- ui and appearance
require("plugins.ui")

-- editor enhancements
require("plugins.editor")

-- tools and utilities
require("plugins.tools")

return {
  { "folke/lazy.nvim", version = "*" },
}
