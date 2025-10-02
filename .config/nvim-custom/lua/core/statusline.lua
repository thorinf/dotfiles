local M = {}

local has_icons, icons = pcall(require, "mini.icons")

local mode_map = {
  n = "normal",
  no = "normal",
  nov = "normal",
  noV = "normal",
  ["no\22"] = "normal",
  niI = "normal",
  niR = "normal",
  niV = "normal",
  v = "visual",
  V = "v-line",
  ["\22"] = "v-block",
  s = "select",
  S = "s-line",
  ["\19"] = "s-block",
  i = "insert",
  ic = "insert",
  ix = "insert",
  R = "replace",
  Rc = "replace",
  Rv = "replace",
  Rx = "replace",
  c = "command",
  cv = "command",
  ce = "command",
  r = "replace",
  rm = "replace",
  ["r?"] = "replace",
  ["!"] = "terminal",
  t = "terminal",
  nt = "terminal",
  o = "operator",
}

local mode_hl = {
  normal = "Directory",
  visual = "Number",
  ["v-line"] = "Number",
  ["v-block"] = "Number",
  select = "Number",
  ["s-line"] = "Number",
  ["s-block"] = "Number",
  insert = "String",
  replace = "String",
  command = "Keyword",
  terminal = "Keyword",
  operator = "Function",
}

local diagnostic_levels = {
  { severity = vim.diagnostic.severity.ERROR, prefix = "E ", hl = "DiagnosticError" },
  { severity = vim.diagnostic.severity.WARN, prefix = "W ", hl = "DiagnosticWarn" },
  { severity = vim.diagnostic.severity.HINT, prefix = "H ", hl = "DiagnosticHint" },
  { severity = vim.diagnostic.severity.INFO, prefix = "I ", hl = "DiagnosticInfo" },
}

local diff_symbols = {
  { field = "added", prefix = "+" },
  { field = "changed", prefix = "~" },
  { field = "removed", prefix = "-" },
}

local function fmt(val, hl)
  return "%#" .. (hl or "Normal") .. "#" .. val .. "%*"
end

local function get_icon(kind, value)
  if not has_icons then
    return nil, nil
  end

  local ok, icon, hl = pcall(icons.get, kind, value)
  if ok and icon and icon ~= "" then
    return icon, hl
  end

  return nil, nil
end

local function get_git_head()
  local status = vim.b.gitsigns_status_dict
  if status and status.head and status.head ~= "" then
    return status.head
  end

  local head = vim.g.gitsigns_head
  if type(head) == "string" and head ~= "" then
    return head
  end
end

local components = {
  mode = {
    render = function()
      local current = vim.api.nvim_get_mode().mode
      local label = mode_map[current] or mode_map[current:sub(1, 1)]
      if not label then
        return ""
      end
      return fmt(label, mode_hl[label])
    end,
  },
  git_branch = {
    hl = "Comment",
    render = function(spec)
      local head = get_git_head()
      if not head then
        return ""
      end
      local parts = {}
      local icon, icon_hl = get_icon("git", "branch")
      if not icon or icon == "" then
        icon = ""
        icon_hl = spec.hl
      end
      parts[#parts + 1] = fmt(icon, icon_hl)
      parts[#parts + 1] = fmt(head, spec.hl)
      return table.concat(parts, " ")
    end,
  },
  git_diff = {
    hl = "Type",
    render = function(spec)
      local summary = vim.b.gitsigns_status_dict
      if not summary then
        return ""
      end
      local diff = {}
      for _, entry in ipairs(diff_symbols) do
        local count = summary[entry.field]
        if count and count > 0 then
          diff[#diff + 1] = entry.prefix .. count
        end
      end
      if #diff == 0 then
        return ""
      end
      return fmt(table.concat(diff, " "), spec.hl)
    end,
  },
  file_name = {
    hl = "Normal",
    render = function(spec)
      local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
      if name == "" then
        return ""
      end

      local parts = {}
      local icon, icon_hl = get_icon("file", name)
      if icon then
        parts[#parts + 1] = fmt(icon, icon_hl)
      end
      parts[#parts + 1] = fmt(name, spec.hl)
      return table.concat(parts, " ")
    end,
  },
  diagnostics = {
    render = function()
      local diagnostics = vim.diagnostic.get(0)
      if not diagnostics or #diagnostics == 0 then
        return ""
      end
      local counts = {}
      for _, item in ipairs(diagnostics) do
        local severity = item.severity
        counts[severity] = (counts[severity] or 0) + 1
      end
      local parts = {}
      for _, level in ipairs(diagnostic_levels) do
        local count = counts[level.severity]
        if count and count > 0 then
          parts[#parts + 1] = fmt(level.prefix .. count, level.hl)
        end
      end
      return table.concat(parts, " ")
    end,
  },
  location = {
    hl = "Comment",
    render = function(spec)
      return fmt("%l:%c", spec.hl)
    end,
  },
  progress = {
    hl = "Comment",
    render = function(spec)
      return fmt("%p%%", spec.hl)
    end,
  },
}

local layout = {
  left = { "mode", "git_branch", "git_diff", "file_name" },
  right = { "diagnostics", "location", "progress" },
}

local function layout_call(region)
  return string.format("%%{%%v:lua.require('core.statusline').evaluate('%s')%%}", region)
end

vim.opt.statusline = table.concat({
  layout_call("left"),
  "%=",
  layout_call("right"),
}, "")

function M.component(name)
  local spec = components[name]
  if not spec or type(spec.render) ~= "function" then
    return ""
  end
  local ok, result = pcall(spec.render, spec)
  if not ok or not result or result == "" then
    return ""
  end
  return result
end

function M.evaluate(region)
  local names = layout[region]
  if not names then
    return ""
  end
  local rendered = {}
  for _, name in ipairs(names) do
    local segment = M.component(name)
    if segment ~= "" then
      rendered[#rendered + 1] = segment
    end
  end
  return table.concat(rendered, "  ")
end

return M
