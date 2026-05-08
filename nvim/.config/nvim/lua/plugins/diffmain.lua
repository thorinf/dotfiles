-- Branch review against origin/main.
--   <leader>gm  pick a file changed working-tree vs origin/main
--   <leader>gb  pick a file your branch added since merge-base (PR-style)
--   <leader>gM  diff the current file vs origin/main
--   Tab/S-Tab   cycle through the picker's file list (in the diff buffers)
--   R           prompt for a REVIEW: comment, insert above the cursor

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
  -- Prefer origin/main (authoritative) over local main, which can be stale.
  for _, ref in ipairs({ "origin/main", "main" }) do
    git(root, { "rev-parse", "--verify", "--quiet", ref .. "^{commit}" })
    if vim.v.shell_error == 0 then
      return ref
    end
  end
  vim.notify("Could not find origin/main or main", vim.log.levels.WARN)
end

local function merge_base(root, ref)
  local mb = git(root, { "merge-base", ref, "HEAD" })[1]
  if vim.v.shell_error ~= 0 or not mb or mb == "" then
    vim.notify("Could not find merge-base with " .. ref, vim.log.levels.WARN)
    return nil
  end
  return mb
end

local function relpath(root, path)
  local abs = vim.fn.fnamemodify(path, ":p")
  root = vim.fn.fnamemodify(root, ":p"):gsub("/$", "")
  if vim.startswith(abs, root .. "/") then
    return abs:sub(#root + 2)
  end
end

-- range_arg is either `<ref>` (working-tree vs ref) or `<ref>...HEAD` (merge-base diff).
local function changed_files(root, range_arg)
  local raw = git(root, { "diff", "--name-status", "--find-renames", "--find-copies", range_arg })
  if vim.v.shell_error ~= 0 then
    vim.notify("Could not compute diff for " .. range_arg, vim.log.levels.WARN)
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

local session = nil
local cycle_review -- forward-declared; assigned below

local function open_review_file(entry, root, base_show, base_label)
  if vim.wo.diff then
    pcall(vim.cmd, "windo diffoff")
    pcall(vim.cmd, "only")
  end

  local branch_path = root .. "/" .. entry.file
  if vim.fn.filereadable(branch_path) == 1 then
    vim.cmd.edit(vim.fn.fnameescape(branch_path))
  else
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
  local left_buf = vim.api.nvim_get_current_buf()
  vim.wo.wrap = false
  vim.wo.foldenable = false
  vim.wo.winbar = "%#Title#branch:%#Normal# " .. entry.file

  local base_path = entry.base_file or entry.file
  local content
  local missing_at_base = false
  if entry.status == "A" then
    missing_at_base = true
  else
    content = git(root, { "show", base_show .. ":" .. base_path })
    if vim.v.shell_error ~= 0 then
      missing_at_base = true
    end
  end
  if missing_at_base then
    content = { "── file not present at " .. base_label .. " ──" }
  else
    for _, ln in ipairs(content) do
      if ln:find("\0", 1, true) then
        content = { "── binary file (skipping diff) ──" }
        break
      end
    end
  end
  local tmp = vim.fn.tempname()
  vim.fn.writefile(content, tmp)

  -- Delete the tempfile whether :diffsplit succeeds or errors so /tmp doesn't grow.
  local ok, err = pcall(vim.cmd, "rightbelow vert diffsplit " .. vim.fn.fnameescape(tmp))
  pcall(vim.fn.delete, tmp)
  if not ok then
    vim.notify("diffsplit failed: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

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
  -- Make the statusline's git_branch component show the base ref on this pane.
  vim.b.gitsigns_status_dict = { head = base_label, added = 0, changed = 0, removed = 0 }
  vim.wo.wrap = false
  vim.wo.foldenable = false
  vim.wo.winbar = "%#Title#" .. base_label .. ":%#Normal# " .. base_path
  local right_buf = vim.api.nvim_get_current_buf()

  for _, buf in ipairs({ left_buf, right_buf }) do
    vim.keymap.set("n", "<Tab>", function()
      cycle_review(1)
    end, { buffer = buf, desc = "Next review file" })
    vim.keymap.set("n", "<S-Tab>", function()
      cycle_review(-1)
    end, { buffer = buf, desc = "Prev review file" })
  end

  if vim.fn.filereadable(branch_path) == 1 then
    vim.keymap.set("n", "R", function()
      local lnum = vim.api.nvim_win_get_cursor(0)[1]
      vim.ui.input({ prompt = "REVIEW: " }, function(input)
        if not input or input == "" then
          return
        end
        local cs = vim.bo[left_buf].commentstring
        if cs == "" then
          cs = "# %s"
        end
        -- Manual split around %s: gsub's replacement string interprets %0/%1 etc.
        local before, after = cs:match("^(.-)%%s(.-)$")
        before = before or ""
        after = after or ""
        local cur = vim.api.nvim_buf_get_lines(left_buf, lnum - 1, lnum, false)[1] or ""
        local indent = cur:match("^%s*") or ""
        local comment = indent .. before .. "REVIEW: " .. input .. after
        vim.api.nvim_buf_set_lines(left_buf, lnum - 1, lnum - 1, false, { comment })
      end)
    end, { buffer = left_buf, desc = "Add REVIEW comment" })
  end

  vim.api.nvim_set_current_win(left)
end

cycle_review = function(delta)
  if not session or #session.entries == 0 then
    return
  end
  if not vim.wo.diff then
    session = nil
    return
  end
  session.index = ((session.index - 1 + delta) % #session.entries) + 1
  open_review_file(session.entries[session.index], session.root, session.base_show, session.base_label)
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
  -- Drop any picker session so Tab is a no-op rather than reviving stale state.
  session = nil
  open_review_file({ status = "M", file = file, base_file = file }, root, ref, ref)
end

local function review_picker(opts)
  opts = opts or {}
  local root = repo_root()
  if not root then
    return
  end
  local ref = base_ref(root)
  if not ref then
    return
  end

  local range_arg, base_show, base_label
  if opts.merge_base then
    local mb = merge_base(root, ref)
    if not mb then
      return
    end
    range_arg = ref .. "...HEAD"
    base_show = mb
    base_label = "base@" .. ref
  else
    range_arg = ref
    base_show = ref
    base_label = ref
  end

  local entries = changed_files(root, range_arg)
  if #entries == 0 then
    vim.notify("No files changed for " .. range_arg, vim.log.levels.INFO)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local entry_display = require("telescope.pickers.entry_display")
  local previewers = require("telescope.previewers")

  local displayer = entry_display.create({
    separator = " ",
    items = { { width = 1 }, { remaining = true } },
  })
  local hl = { A = "DiffAdd", M = "DiffChange", D = "DiffDelete", R = "Type", C = "Type" }

  local diff_previewer = previewers.new_buffer_previewer({
    title = "Diff (" .. range_arg .. ")",
    define_preview = function(self, entry)
      local target = entry.value.base_file or entry.value.file
      local lines = git(root, { "diff", "--no-color", range_arg, "--", target })
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
      vim.bo[self.state.bufnr].filetype = "diff"
    end,
  })

  pickers
    .new({}, {
      prompt_title = "Changed files (" .. range_arg .. ")",
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
      previewer = diff_previewer,
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry then
            local idx = 1
            for i, e in ipairs(entries) do
              if e.file == entry.value.file then
                idx = i
                break
              end
            end
            session = {
              entries = entries,
              index = idx,
              root = root,
              base_show = base_show,
              base_label = base_label,
            }
            open_review_file(entry.value, root, base_show, base_label)
          end
        end)
        return true
      end,
    })
    :find()
end

vim.keymap.set("n", "<leader>gm", function()
  review_picker()
end, { desc = "Pick changed file vs main (working tree)" })

vim.keymap.set("n", "<leader>gb", function()
  review_picker({ merge_base = true })
end, { desc = "Pick changed file vs main (since merge-base)" })

vim.keymap.set("n", "<leader>gM", review_current_file, { desc = "Review current file vs main" })
