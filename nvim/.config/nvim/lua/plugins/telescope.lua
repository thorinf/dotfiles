require("mini.icons").setup({})
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

pcall(telescope.load_extension, "fzf")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>f.", function()
  builtin.find_files({ hidden = true })
end, { desc = "Find files (hidden)" })

vim.keymap.set("n", "<leader>fd", function()
  local config_path = vim.fn.resolve(vim.fn.stdpath("config"))
  local dotfiles_path = vim.fn.fnamemodify(config_path, ":h:h:h")
  builtin.live_grep({ cwd = dotfiles_path, hidden = true })
end, { desc = "Live grep dotfiles" })

vim.keymap.set("n", "<leader>fr", function()
  local code_exts = {
    py = true,
    pyx = true,
    pyi = true,
    cs = true,
    c = true,
    h = true,
    cc = true,
    hh = true,
    cpp = true,
    hpp = true,
    cxx = true,
    hxx = true,
    cu = true,
    cuh = true,
    ts = true,
    tsx = true,
    js = true,
    jsx = true,
    mjs = true,
    cjs = true,
    go = true,
    rs = true,
    rb = true,
    java = true,
    kt = true,
    scala = true,
    swift = true,
    lua = true,
    vim = true,
    sh = true,
    bash = true,
    zsh = true,
    fish = true,
    ps1 = true,
    html = true,
    css = true,
    scss = true,
    sass = true,
    md = true,
    mdx = true,
    sql = true,
    nix = true,
    tf = true,
    proto = true,
  }
  local root = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })[1]
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repo", vim.log.levels.WARN)
    return
  end
  local all = vim.fn.systemlist({ "git", "-C", root, "ls-files" })
  local files = {}
  for _, f in ipairs(all) do
    if code_exts[vim.fn.fnamemodify(f, ":e")] then
      files[#files + 1] = f
    end
  end
  if #files == 0 then
    vim.notify("No code files found", vim.log.levels.WARN)
    return
  end
  local file = root .. "/" .. files[math.random(#files)]
  vim.cmd.edit(vim.fn.fnameescape(file))
end, { desc = "Find random git file" })
