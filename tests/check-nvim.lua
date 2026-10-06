-- Run: NVIM_LOG_FILE=/tmp/dotfiles-nvim.log nvim --headless -u NONE -i NONE -l tests/check-nvim.lua
local repo = vim.fn.fnamemodify(arg[0], ":p:h:h")
vim.opt.runtimepath:prepend(repo .. "/nvim/.config/nvim")
vim.g.mapleader = " "
vim.opt.hidden = true
local scratch = vim.fn.tempname()
vim.fn.mkdir(scratch, "p")
scratch = assert(vim.uv.fs_realpath(scratch))

local function up(fn, wanted)
  for i = 1, 50 do
    local name, value = debug.getupvalue(fn, i)
    if name == wanted then
      return value
    end
    if not name then
      break
    end
  end
  error("Missing upvalue: " .. wanted)
end

local function git(root, ...)
  local args = {
    "git",
    "-c",
    "user.name=Test",
    "-c",
    "user.email=test@localhost",
    "-c",
    "commit.gpgsign=false",
    "-c",
    "core.hooksPath=/dev/null",
    "-C",
    root,
  }
  vim.list_extend(args, { ... })
  local result = vim.fn.systemlist(args)
  assert(vim.v.shell_error == 0, table.concat(result, "\n"))
  return result
end

local function fixture(name)
  local root = scratch .. "/" .. name
  vim.fn.mkdir(root, "p")
  git(root, "init", "-b", "main")
  vim.fn.writefile({ "base" }, root .. "/a.txt")
  vim.fn.writefile({ "base" }, root .. "/b.txt")
  git(root, "add", ".")
  git(root, "commit", "-m", "base")
  return root
end

local function check()
  local root, other = fixture("first"), fixture("second")
  require("plugins.diffmain")
  local current = vim.fn.maparg(" gM", "n", false, true).callback
  local open = up(current, "open_review_file")
  git(root, "switch", "-c", "feature")
  vim.fn.writefile({ "committed" }, root .. "/a.txt")
  git(root, "commit", "-am", "branch change")
  vim.fn.writefile({ "local edit" }, root .. "/a.txt")
  vim.fn.writefile({ "local edit" }, root .. "/b.txt")
  local picker = up(vim.fn.maparg(" gm", "n", false, true).callback, "review_picker")
  local target = up(picker, "diff_target")(root, { base = "main", merge_base = true })
  assert(target.range_arg == target.base_show)
  local entries = up(picker, "changed_files")(root, target.range_arg)
  assert(#entries == 2 and entries[1].file == "a.txt" and entries[2].file == "b.txt")
  assert(table.concat(git(root, "diff", target.range_arg), "\n"):find("+local edit", 1, true))
  vim.cmd.edit(root .. "/a.txt")
  local original_r = function() end
  vim.keymap.set("n", "R", original_r, { buffer = true, desc = "Original R" })
  vim.wo.wrap, vim.wo.foldenable, vim.wo.winbar = true, true, "original"
  open({ file = "a.txt", status = "M", base_file = "a.txt" }, root, "main", "main")
  local left = vim.api.nvim_get_current_win()
  local right = vim.fn.win_getid(vim.fn.winnr("l"))
  assert(vim.bo.modifiable and not vim.bo.readonly)
  assert(not vim.bo[vim.api.nvim_win_get_buf(right)].modifiable)
  assert(vim.fn.maparg("R", "n", false, true).desc == "Add REVIEW comment")
  open({ file = "b.txt", status = "M", base_file = "b.txt" }, root, "main", "main")
  assert(#vim.api.nvim_list_wins() == 2)
  vim.api.nvim_win_close(vim.fn.win_getid(vim.fn.winnr("l")), true)
  vim.wait(50)
  assert(vim.fn.maparg("R", "n", false, true).desc == nil)
  assert(vim.fn.maparg("<Tab>", "n", false, true).desc == nil)
  assert(vim.w.diffmain_root == nil)
  assert(vim.wo.wrap and vim.wo.foldenable and vim.wo.winbar == "original" and not vim.wo.diff)
  vim.cmd.edit(root .. "/a.txt")
  assert(vim.fn.maparg("R", "n", false, true).callback == original_r)

  open({ file = "a.txt", status = "M", base_file = "a.txt" }, root, "main", "main")
  vim.cmd("diffoff!")
  vim.cmd("doautocmd OptionSet diff")
  vim.wait(50)
  assert(#vim.api.nvim_list_wins() == 1 and vim.w.diffmain_root == nil)
  vim.cmd.edit(other .. "/a.txt")
  vim.cmd.cd(other)
  assert(up(current, "repo_root")() == other)
  assert(vim.fn.maparg("<Tab>", "n", false, true).desc == nil)

  open({ file = "a.txt", status = "M", base_file = "a.txt" }, root, "main", "main")
  vim.cmd.edit(other .. "/b.txt")
  vim.wait(50)
  assert(#vim.api.nvim_list_wins() == 1 and vim.w.diffmain_root == nil)
  assert(up(current, "repo_root")() == other)

  open({ file = "a.txt", status = "M", base_file = "a.txt" }, root, "main", "main")
  vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
  vim.wait(50)
  assert(#vim.api.nvim_list_wins() == 1 and vim.w.diffmain_root == nil)
  assert(vim.bo.modifiable and not vim.bo.readonly)
  assert(vim.api.nvim_buf_get_name(0) == root .. "/a.txt")

  local names = fixture("names")
  local unusual = 'caf\195\169\tline\nquote"%.txt'
  local renamed = "renamed\tfile.txt"
  vim.fn.writefile({ "original" }, names .. "/" .. unusual)
  vim.fn.writefile({ "rename content" }, names .. "/b.txt")
  git(names, "add", ".")
  git(names, "commit", "-m", "unusual filenames")
  git(names, "switch", "-c", "feature")
  git(names, "mv", "b.txt", renamed)
  git(names, "rm", "a.txt")
  vim.fn.writefile({ "modified" }, names .. "/" .. unusual)
  vim.fn.writefile({ "added" }, names .. "/added.txt")
  git(names, "add", "added.txt")
  local by_name = {}
  for _, entry in ipairs(up(picker, "changed_files")(names, "main")) do
    by_name[entry.file] = entry
  end
  assert(by_name[unusual].status == "M" and by_name[unusual].base_file == unusual)
  assert(by_name[renamed].status == "R" and by_name[renamed].base_file == "b.txt")
  assert(by_name["a.txt"].status == "D")
  assert(by_name["added.txt"].status == "A" and by_name["added.txt"].base_file == nil)
  open(by_name[unusual], names, "main", "main")
  assert(vim.api.nvim_get_current_line() == "modified")
  assert(vim.api.nvim_buf_get_name(0) == names .. "/" .. unusual)
  vim.cmd("diffoff!")
  vim.cmd("doautocmd OptionSet diff")
  vim.wait(50)

  local conform_config
  package.loaded.conform = {
    setup = function(config)
      conform_config = config
    end,
  }
  package.loaded.mason = { setup = function() end }
  package.loaded["mason-lspconfig"] = { setup = function() end }
  package.loaded["blink.cmp"] = {}
  require("plugins.lsp")
  package.loaded.conform = nil
  vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site/pack/core/opt/conform.nvim")
  local python = scratch .. "/python"
  vim.fn.mkdir(python, "p")
  vim.fn.writefile({ "[project]", 'name = "test"', 'version = "0.1.0"' }, python .. "/pyproject.toml")
  local real_executable = vim.fn.executable
  vim.fn.executable = function(name)
    return name == "uv" and 1 or real_executable(name)
  end
  local ctx = { dirname = python, filename = python .. "/a.py", bufnr = 0 }
  for _, name in ipairs({ "ruff_fix", "ruff_format" }) do
    local override = conform_config.formatters[name]
    assert(override.command(override, ctx) == "uv")
    local config = vim.tbl_extend("force", require("conform.formatters." .. name), override)
    local cmd = require("conform.runner").build_cmd(name, ctx, config)
    assert(vim.fn.fnamemodify(cmd[1], ":t") == "uv" and cmd[2] == "run" and cmd[3] == "ruff")
    assert(cmd[4] == (name == "ruff_fix" and "check" or "format"))
  end
  ctx.range = { start = { 1, 0 }, ["end"] = { 2, 0 } }
  local config =
    vim.tbl_extend("force", require("conform.formatters.ruff_format"), conform_config.formatters.ruff_format)
  local cmd = require("conform.runner").build_cmd("ruff_format", ctx, config)
  assert(cmd[2] == "run" and cmd[3] == "ruff" and cmd[4] == "format")
  assert(vim.tbl_contains(cmd, "--range"))

  local launched, launch_opts
  local real_start = vim.lsp.rpc.start
  vim.lsp.rpc.start = function(argv, _, opts)
    launched, launch_opts = argv, opts
    return { test = true }
  end
  assert(vim.lsp.config.ruff.before_init == nil)
  assert(vim.lsp.config.ruff.cmd({}, { root_dir = python }).test)
  assert(vim.deep_equal(launched, { "uv", "run", "ruff", "server" }))
  assert(launch_opts.cwd == python)
  assert(vim.lsp.config.ruff.cmd({}, { root_dir = other }).test)
  assert(vim.deep_equal(launched, { "ruff", "server" }))
  assert(launch_opts.cwd == other)
  vim.lsp.rpc.start = real_start
  vim.fn.executable = real_executable
end

local ok, err = pcall(check)
vim.fn.delete(scratch, "rf")
assert(ok, err)
print("Neovim regression checks passed")
vim.cmd("qa!")
