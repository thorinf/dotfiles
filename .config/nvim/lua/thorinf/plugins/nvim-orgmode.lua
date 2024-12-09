
local setup, orgmode = pcall(require, "orgmode")
if not setup then
  vim.notify("nvim-orgmode not found", vim.log.levels.ERROR)
  return
end

orgmode.setup({
  org_agenda_files = {'~/org/**/*'},
  org_default_notes_file = '~/org/refile.org',
})
