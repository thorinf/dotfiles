-- Branch review against origin/main: pick a file from a fuzzy list and view it
-- diffed inline. Left pane = the live file (LSP attaches normally). Right pane =
-- a read-only scratch buffer holding the base ref's version of the file.
--
-- Bindings:
--   <leader>gm  pick a file changed vs origin/main, open in diff
--   <leader>gM  diff the current file vs origin/main

local function git(root, args)
  local argv = { "git", "-C", root }
  vim.list_extend(argv, args)
  return vim.fn.systemlist(argv)
end

local function repo_root()
  local root = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })[1]
  if vim.v.shell_error ~= 0 or not root or root == "" then
    vim.notify("Not in a git repo", vim.log.levels.WARN)
    return nil
  end
  return root
end

local function base_ref(root)
  -- Prefer origin/main (authoritative); fall back to local main.
  for _, ref in ipairs({ "origin/main", "main" }) do
    git(root, { "rev-parse", "--verify", "--quiet", ref .. "^{commit}" })
    if vim.v.shell_error == 0 then
      return ref
    end
  end
  vim.notify("Could not find origin/main or main", vim.log.levels.WARN)
end

local function relpath(root, path)
  local abs = vim.fn.fnamemodify(path, ":p")
  root = vim.fn.fnamemodify(root, ":p"):gsub("/$", "")
  if vim.startswith(abs, root .. "/") then
    return abs:sub(#root + 2)
  end
end

local function changed_files(root, ref)
  -- Working tree vs ref: captures every difference between what the user is editing
  -- right now and the base branch. This includes uncommitted local edits AND any
  -- committed-but-not-yet-on-base work. Avoids merge-base false positives where the
  -- branch "added" a file that origin/main has independently absorbed.
  local raw = git(root, { "diff", "--name-status", "--find-renames", "--find-copies", ref })
  if vim.v.shell_error ~= 0 then
    vim.notify("Could not compute diff against " .. ref, vim.log.levels.WARN)
    return {}
  end

  local entries = {}
  for _, line in ipairs(raw) do
    local parts = vim.split(line, "\t", { plain = true })
    local status = parts[1]:sub(1, 1)
    local file = parts[#parts]
    local base_file = status == "A" and nil or file
    if status == "R" or status == "C" then
      base_file = parts[2]
    end
    entries[#entries + 1] = { status = status, file = file, base_file = base_file }
  end
  table.sort(entries, function(a, b)
    return a.file < b.file
  end)
  return entries
end

local function open_review_file(entry, root, base, base_label)
  -- Tear down any existing diff layout.
  if vim.wo.diff then
    pcall(vim.cmd, "windo diffoff")
    pcall(vim.cmd, "only")
  end

  -- Left pane: open the actual file (LSP attaches normally).
  local branch_path = root .. "/" .. entry.file
  if vim.fn.filereadable(branch_path) == 1 then
    vim.cmd.edit(vim.fn.fnameescape(branch_path))
  else
    -- File deleted on this branch — placeholder scratch buffer on the left.
    vim.cmd("enew")
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.swapfile = false
    vim.bo.modifiable = true
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "── file deleted on this branch ──" })
    vim.bo.modifiable = false
    vim.bo.readonly = true
  end
  local left = vim.api.nvim_get_current_win()
  vim.wo.wrap = false
  vim.wo.foldenable = false
  vim.wo.winbar = "%#Title#branch:%#Normal# " .. entry.file

  -- Right pane: write base content to a tempfile and use :diffsplit.
  local base_path = entry.base_file or entry.file
  local content
  local missing_at_base = false
  if entry.status == "A" then
    missing_at_base = true
  else
    content = git(root, { "show", base .. ":" .. base_path })
    if vim.v.shell_error ~= 0 then
      missing_at_base = true
    end
  end
  if missing_at_base then
    content = { "── file not present at " .. base_label .. " ──" }
  end
  local tmp = vim.fn.tempname()
  vim.fn.writefile(content, tmp)

  vim.cmd("rightbelow vert diffsplit " .. vim.fn.fnameescape(tmp))

  -- Mark right buffer as read-only scratch and make the statusline show the base ref.
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.modifiable = false
  vim.bo.readonly = true
  pcall(vim.api.nvim_buf_set_name, 0, base_label .. ":" .. base_path)
  local ft = vim.filetype.match({ filename = base_path })
  if ft then
    vim.bo.filetype = ft
  end
  vim.b.gitsigns_status_dict = { head = base_label, added = 0, changed = 0, removed = 0 }
  vim.wo.wrap = false
  vim.wo.foldenable = false
  vim.wo.winbar = "%#Title#" .. base_label .. ":%#Normal# " .. base_path

  -- End focused on the live (left) pane.
  vim.api.nvim_set_current_win(left)
end

local function review_current_file()
  local root = repo_root()
  if not root then
    return
  end
  local ref = base_ref(root)
  if not ref then
    return
  end
  local file = relpath(root, vim.api.nvim_buf_get_name(0))
  if not file then
    vim.notify("Current file is outside the git repo", vim.log.levels.WARN)
    return
  end
  open_review_file({ status = "M", file = file, base_file = file }, root, ref, ref)
end

local function review_picker()
  local root = repo_root()
  if not root then
    return
  end
  local ref = base_ref(root)
  if not ref then
    return
  end
  local entries = changed_files(root, ref)
  if #entries == 0 then
    vim.notify("No files changed vs " .. ref, vim.log.levels.INFO)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local entry_display = require("telescope.pickers.entry_display")

  local displayer = entry_display.create({
    separator = " ",
    items = { { width = 1 }, { remaining = true } },
  })
  local hl = { A = "DiffAdd", M = "DiffChange", D = "DiffDelete", R = "Type", C = "Type" }

  pickers
    .new({}, {
      prompt_title = "Changed files vs " .. ref,
      finder = finders.new_table({
        results = entries,
        entry_maker = function(e)
          return {
            value = e,
            ordinal = e.file,
            display = function()
              return displayer({ { e.status, hl[e.status] or "Normal" }, e.file })
            end,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry then
            open_review_file(entry.value, root, ref, ref)
          end
        end)
        return true
      end,
    })
    :find()
end

vim.keymap.set("n", "<leader>gm", review_picker, { desc = "Pick changed file vs main" })
vim.keymap.set("n", "<leader>gM", review_current_file, { desc = "Review current file vs main" })
