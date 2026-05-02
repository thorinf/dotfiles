-- vim.pack: built-in plugin manager (Neovim 0.12+).
-- Replaces lazy.nvim. Plugins are cloned on first startup and added to runtimepath.
-- See :h vim.pack and https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack

-- Register build hooks BEFORE add() so PackChanged fires on initial install.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("PackBuilds", { clear = true }),
  callback = function(ev)
    local name = ev.data and ev.data.spec and ev.data.spec.name
    local path = ev.data and ev.data.path
    if not name or not path then
      return
    end
    if name == "telescope-fzf-native.nvim" then
      vim.system({ "make" }, { cwd = path }):wait()
    elseif name == "LuaSnip" then
      vim.system({ "make", "install_jsregexp" }, { cwd = path }):wait()
    end
  end,
})

vim.pack.add({
  -- colorscheme (load first so other plugins can reference its highlights)
  { src = "https://github.com/scottmckendry/cyberdream.nvim" },

  -- completion + snippets
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.x") },
  { src = "https://github.com/L3MON4D3/LuaSnip" },

  -- LSP + formatter
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/aznhe21/actions-preview.nvim" },
  { src = "https://github.com/rachartier/tiny-code-action.nvim" },
  { src = "https://github.com/seblyng/roslyn.nvim" },

  -- finder + utilities
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
  { src = "https://github.com/echasnovski/mini.icons" },

  -- git
  { src = "https://github.com/lewis6991/gitsigns.nvim" },

  -- editing / nav
  { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/mbbill/undotree" },
  { src = "https://github.com/folke/which-key.nvim" },

  -- lua dev
  { src = "https://github.com/folke/lazydev.nvim" },
  { src = "https://github.com/Bilal2453/luvit-meta" },
})

-- Belt-and-braces: ensure compiled artifacts exist even if PackChanged was missed.
local data_pack = vim.fn.stdpath("data") .. "/site/pack/core/opt"
local fzf_dir = data_pack .. "/telescope-fzf-native.nvim"
if vim.uv.fs_stat(fzf_dir) and not vim.uv.fs_stat(fzf_dir .. "/build/libfzf.so") then
  vim.system({ "make" }, { cwd = fzf_dir }):wait()
end
