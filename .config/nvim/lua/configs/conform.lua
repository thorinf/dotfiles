-- Prefer project-local Ruff if available
local function prefer_local_ruff(ctx)
  local filename = (ctx and ctx.filename) or vim.api.nvim_buf_get_name(0)
  local start = vim.fs.dirname(filename)
  -- 1) Prefer project-local ruff
  local found = vim.fs.find({ ".venv/bin/ruff", "venv/bin/ruff" }, { upward = true, path = start })[1]
  if found and vim.fn.executable(found) == 1 then
    return found
  end
  -- 2) Fallback to system PATH
  return "ruff"
end

local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_fix", "ruff_format" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },

  -- Formatter overrides
  formatters = {
    ruff_fix = {
      command = prefer_local_ruff,
    },
    ruff_format = {
      command = prefer_local_ruff,
    },
  },
}

return options
