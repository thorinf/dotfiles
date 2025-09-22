return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  main = "nvim-treesitter.configs",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects", -- motions / selection
    -- Optional niceties:
    -- "nvim-treesitter/nvim-treesitter-context",  -- sticky function/class header
  },
  opts = {
    ensure_installed = {
      -- Editor/Lua (Neovim runtime)
      "lua",
      "vim",
      "vimdoc",
      "query",
      -- Your stack
      "c",
      "cpp",
      "python",
      -- Docs/data
      "markdown",
      "markdown_inline",
      "toml",
      "yaml",
      "json",
      -- Shell (handy)
      "bash",
    },

    sync_install = false,
    auto_install = true,

    highlight = {
      enable = true,
      -- Large-file guard (keeps things snappy on vendor/log files)
      disable = function(_, buf)
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        return ok and stats and stats.size > 200 * 1024 -- >200KB
      end,
      additional_vim_regex_highlighting = false,
    },

    -- Treesitter-based motions/selection (requires textobjects dep)
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["ap"] = "@parameter.outer",
          ["ip"] = "@parameter.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
        goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
      },
    },

    -- Indent is decent for C/C++; flaky for Python → disable there only
    indent = { enable = true, disable = { "python" } },

    -- Incremental selection (super handy once you learn it)
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>",
        node_incremental = "<CR>",
        node_decremental = "<BS>",
        scope_incremental = "<TAB>",
      },
    },
  },
}
