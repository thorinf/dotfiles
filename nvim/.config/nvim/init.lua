vim.loader.enable()

require("core.options")
require("core.keymaps")

-- Install/load plugins via vim.pack (built-in, replaces lazy.nvim).
require("config.pack")

-- Per-plugin setup. Each file calls .setup() and registers keymaps directly.
require("plugins.colorscheme")
require("plugins.cmp")
require("plugins.lsp")
require("plugins.telescope")
require("plugins.gitsigns")
require("plugins.harpoon")
require("plugins.oil")
require("plugins.undotree")
require("plugins.whichkey")
require("plugins.lazydev")
require("plugins.treesitter")

require("core.statusline")
