return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "echasnovski/mini.icons", opts = {} },
  },
  config = function()
    require("mini.icons").mock_nvim_web_devicons()

    local telescope = require("telescope")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = require("telescope.themes").get_ivy({
        file_ignore_patterns = { "node_modules", ".git/" },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
        },
      }),
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })

    telescope.load_extension("fzf")
  end,
  keys = {
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files()
      end,
      desc = "Find files",
    },
    {
      "<leader>fg",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "Live grep",
    },
    {
      "<leader>fb",
      function()
        require("telescope.builtin").buffers()
      end,
      desc = "Buffers",
    },
    {
      "<leader>fh",
      function()
        require("telescope.builtin").help_tags()
      end,
      desc = "Help tags",
    },
    {
      "<leader>fc",
      function()
        require("telescope.builtin").live_grep({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "Live grep config",
    },
    {
      "<leader>fd",
      function()
        -- resolve symlink and go up to dotfiles root
        local config_path = vim.fn.resolve(vim.fn.stdpath("config"))
        local dotfiles_path = vim.fn.fnamemodify(config_path, ":h:h:h")
        require("telescope.builtin").live_grep({ cwd = dotfiles_path })
      end,
      desc = "Live grep dotfiles",
    },
    {
      "<leader>f.",
      function()
        require("telescope.builtin").find_files({ hidden = true })
      end,
      desc = "Find files (hidden)",
    },
  },
}
