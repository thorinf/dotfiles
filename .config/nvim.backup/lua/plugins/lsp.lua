-- language server protocol
return {
  -- lsp configuration
  require("plugins.lsp.lspconfig"),
  
  -- package manager for lsp servers
  require("plugins.lsp.mason"),
  
  -- formatting and linting
  require("plugins.lsp.none-ls"),
  
  -- rust-specific tools
  require("plugins.lsp.rust"),
}