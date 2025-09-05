local options = {
  filters = {
    dotfiles = false,        -- Show dotfiles (.hidden files)
    git_ignored = false,     -- Show git ignored files
    git_clean = false,       -- Show git clean files
    no_buffer = false,       -- Show files not loaded in buffer
    custom = {},             -- No custom filters
  },
  
  git = {
    enable = true,
    ignore = false,          -- Don't hide git ignored files
    show_on_dirs = true,     -- Show git status on directories
    show_on_open_dirs = true,
  },
  
  view = {
    adaptive_size = false,
    centralize_selection = false,
    width = 30,
    side = "left",
  },
  
  renderer = {
    highlight_git = true,
    highlight_opened_files = "none",
    
    indent_markers = {
      enable = false,
      inline_arrows = true,
      icons = {
        corner = "└",
        edge = "│",
        item = "│",
        none = " ",
      },
    },
    
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
      
      glyphs = {
        default = "󰈚",
        symlink = "",
        folder = {
          arrow_closed = "",
          arrow_open = "",
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
          symlink_open = "",
        },
        git = {
          unstaged = "✗",
          staged = "✓",
          unmerged = "",
          renamed = "➜",
          untracked = "★",
          deleted = "",
          ignored = "◌",
        },
      },
    },
  },
}

return options