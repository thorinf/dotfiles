-- Minimal Tidal Cycles plugin
local M = {}

local state = {
  term_chan = nil,
  term_buf = nil,
  term_win = nil,
  playing = {}, -- [bufnr][n] = extmark_id
}

local config = {
  boot_file = vim.fn.expand("~/.config/tidal/BootTidal.hs"),
  split = "vsplit",
}

local ns_flash = vim.api.nvim_create_namespace("tidal_flash")
local ns_signs = vim.api.nvim_create_namespace("tidal_signs")

-- Scroll terminal to bottom
local function scroll_terminal()
  if state.term_win and vim.api.nvim_win_is_valid(state.term_win) and state.term_buf then
    local line_count = vim.api.nvim_buf_line_count(state.term_buf)
    pcall(vim.api.nvim_win_set_cursor, state.term_win, { line_count, 0 })
  end
end

-- Send text to ghci
local function send(text)
  if not state.term_chan then
    vim.notify("Tidal not running. Use :Tidal to start", vim.log.levels.WARN)
    return false
  end
  local ok = pcall(vim.fn.chansend, state.term_chan, text .. "\n")
  if not ok then
    vim.notify("Failed to send to Tidal", vim.log.levels.ERROR)
    return false
  end
  vim.defer_fn(scroll_terminal, 50)
  return true
end

-- Send with multiline wrapping
local function send_lines(lines)
  if not lines or #lines == 0 then return end
  if #lines > 1 then
    send(":{\n" .. table.concat(lines, "\n") .. "\n:}")
  else
    send(lines[1])
  end
end

-- Get paragraph/block around cursor
local function get_block()
  local cursor = vim.fn.line(".")
  local start = cursor
  local finish = cursor

  while start > 1 do
    local line = vim.fn.getline(start - 1)
    if line:match("^%s*$") then break end
    start = start - 1
  end

  local last = vim.fn.line("$")
  while finish < last do
    local line = vim.fn.getline(finish + 1)
    if line:match("^%s*$") then break end
    finish = finish + 1
  end

  return start, finish
end

-- Flash highlight on sent region
local function flash(bufnr, start_line, end_line)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  for i = start_line, end_line do
    vim.api.nvim_buf_add_highlight(bufnr, ns_flash, "IncSearch", i - 1, 0, -1)
  end
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, ns_flash, 0, -1)
    end
  end, 150)
end

-- Add playing sign for pattern
local function add_sign(bufnr, n, line)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  state.playing[bufnr] = state.playing[bufnr] or {}

  -- Remove existing sign for this pattern
  if state.playing[bufnr][n] then
    pcall(vim.api.nvim_buf_del_extmark, bufnr, ns_signs, state.playing[bufnr][n])
  end

  -- Add new sign (extmark tracks line changes)
  local mark_id = vim.api.nvim_buf_set_extmark(bufnr, ns_signs, line - 1, 0, {
    sign_text = "▶",
    sign_hl_group = "DiagnosticOk",
  })
  state.playing[bufnr][n] = mark_id
end

-- Remove playing sign for pattern
local function remove_sign(bufnr, n)
  if not state.playing[bufnr] or not state.playing[bufnr][n] then return end
  pcall(vim.api.nvim_buf_del_extmark, bufnr, ns_signs, state.playing[bufnr][n])
  state.playing[bufnr][n] = nil
end

-- Clear all signs in buffer
local function clear_signs(bufnr)
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_clear_namespace(bufnr, ns_signs, 0, -1)
  end
  state.playing[bufnr] = nil
end

-- Find pattern dN in buffer, returns line number
local function find_pattern(bufnr, n)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local pattern = "^%s*d" .. n .. "[%s%$]"
  local pattern_eol = "^%s*d" .. n .. "$"
  for i, line in ipairs(lines) do
    if line:match(pattern) or line:match(pattern_eol) then
      return i
    end
  end
  return nil
end

-- Send block at cursor
function M.send_block()
  local bufnr = vim.api.nvim_get_current_buf()
  local start, finish = get_block()
  local lines = vim.api.nvim_buf_get_lines(bufnr, start - 1, finish, false)
  if #lines > 0 and not lines[1]:match("^%s*$") then
    send_lines(lines)
    flash(bufnr, start, finish)
  end
end

-- Send current line
function M.send_line()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_get_current_line()
  if not line:match("^%s*$") then
    send(line)
    flash(bufnr, vim.fn.line("."), vim.fn.line("."))
  end
end

-- Hush all
function M.hush()
  send("hush")
  -- Clear signs in all tidal buffers
  for bufnr, _ in pairs(state.playing) do
    clear_signs(bufnr)
  end
  state.playing = {}
end

-- Jump to pattern dN
function M.jump(n)
  local bufnr = vim.api.nvim_get_current_buf()
  local line = find_pattern(bufnr, n)
  if line then
    vim.fn.cursor(line, 1)
  else
    vim.notify("d" .. n .. " not found", vim.log.levels.WARN)
  end
end

-- Play pattern dN (find, send, mark as playing)
function M.play(n)
  local bufnr = vim.api.nvim_get_current_buf()
  local line = find_pattern(bufnr, n)
  if line then
    local save = vim.fn.winsaveview()
    vim.fn.cursor(line, 1)
    local start, finish = get_block()
    local lines = vim.api.nvim_buf_get_lines(bufnr, start - 1, finish, false)
    send_lines(lines)
    flash(bufnr, start, finish)
    vim.fn.winrestview(save)
    add_sign(bufnr, n, start)
  else
    vim.notify("d" .. n .. " not found", vim.log.levels.WARN)
  end
end

-- Silence pattern dN
function M.silence(n)
  local bufnr = vim.api.nvim_get_current_buf()
  send("d" .. n .. " silence")
  remove_sign(bufnr, n)
end

-- Toggle pattern dN
function M.toggle(n)
  local bufnr = vim.api.nvim_get_current_buf()
  state.playing[bufnr] = state.playing[bufnr] or {}
  if state.playing[bufnr][n] then
    M.silence(n)
  else
    M.play(n)
  end
end

-- Start tidal
function M.start()
  if state.term_chan then
    vim.notify("Tidal already running", vim.log.levels.WARN)
    return
  end

  local current_win = vim.api.nvim_get_current_win()
  vim.cmd(config.split)
  vim.cmd("terminal ghci -ghci-script=" .. vim.fn.shellescape(config.boot_file))

  state.term_buf = vim.api.nvim_get_current_buf()
  state.term_win = vim.api.nvim_get_current_win()
  state.term_chan = vim.b.terminal_job_id

  -- Return to code window
  vim.api.nvim_set_current_win(current_win)

  vim.api.nvim_create_autocmd("TermClose", {
    buffer = state.term_buf,
    once = true,
    callback = function()
      state.term_chan = nil
      state.term_buf = nil
      state.term_win = nil
      for bufnr, _ in pairs(state.playing) do
        clear_signs(bufnr)
      end
      state.playing = {}
    end,
  })
end

-- Stop tidal
function M.stop()
  if state.term_buf and vim.api.nvim_buf_is_valid(state.term_buf) then
    vim.api.nvim_buf_delete(state.term_buf, { force = true })
  end
  state.term_chan = nil
  state.term_buf = nil
  state.term_win = nil
  for bufnr, _ in pairs(state.playing) do
    clear_signs(bufnr)
  end
  state.playing = {}
end

-- Setup keymaps for tidal files
local function setup_keymaps()
  local opts = { buffer = true, silent = true }

  vim.keymap.set({ "n", "i" }, "<C-e>", function()
    if vim.fn.mode() == "i" then vim.cmd("stopinsert") end
    M.send_block()
  end, opts)

  vim.keymap.set("x", "<C-e>", function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    vim.schedule(function()
      local bufnr = vim.api.nvim_get_current_buf()
      local start = vim.fn.line("'<")
      local finish = vim.fn.line("'>")
      local lines = vim.api.nvim_buf_get_lines(bufnr, start - 1, finish, false)
      send_lines(lines)
      flash(bufnr, start, finish)
    end)
  end, opts)

  vim.keymap.set("n", "<C-h>", M.hush, opts)

  for i = 1, 9 do
    vim.keymap.set("n", "<C-" .. i .. ">", function() M.toggle(i) end, opts)
  end

  vim.keymap.set("n", "<C-0>", function() M.toggle(10) end, opts)

  for i = 1, 9 do
    vim.keymap.set("n", "<leader>" .. i, function() M.jump(i) end, opts)
  end
  vim.keymap.set("n", "<leader>0", function() M.jump(10) end, opts)

  vim.keymap.set("n", "<leader>d", function()
    local char = vim.fn.getchar()
    local n = tonumber(vim.fn.nr2char(char))
    if n then
      M.silence(n == 0 and 10 or n)
    end
  end, opts)
end

-- Plugin setup (for lazy.nvim)
return {
  dir = ".",
  name = "tidal",
  ft = "tidal",
  init = function()
    vim.filetype.add({ extension = { tidal = "tidal" } })
    vim.treesitter.language.register("haskell", "tidal")
  end,
  config = function()
    vim.api.nvim_create_user_command("Tidal", M.start, { desc = "Start Tidal" })
    vim.api.nvim_create_user_command("TidalStop", M.stop, { desc = "Stop Tidal" })
    vim.api.nvim_create_user_command("TidalHush", M.hush, { desc = "Hush all patterns" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "tidal",
      callback = function()
        vim.bo.syntax = "haskell"
        setup_keymaps()
      end,
    })

    -- Handle case where plugin loads after FileType event
    if vim.bo.filetype == "tidal" then
      vim.bo.syntax = "haskell"
      setup_keymaps()
    end
  end,
}
