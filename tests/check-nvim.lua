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
end

local ok, err = pcall(check)
vim.fn.delete(scratch, "rf")
assert(ok, err)
print("Neovim regression checks passed")
vim.cmd("qa!")
