-- editor enhancements
return {
  -- commenting support
  require("plugins.editor.comment"),
  
  -- auto-trim whitespace
  require("plugins.editor.trim"),
  
  -- tmux navigation
  require("plugins.editor.vim-tmux-navigator"),
  
  -- colorful brackets
  require("plugins.editor.rainbow-delimiters"),
  
  -- column guide
  require("plugins.editor.smartcolumn"),
}