return {
  "obsidian-nvim/obsidian.nvim",
  version = "v1.*",
  ft = "markdown",
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false,
    note_id_func = function(title)
      local timestamp = os.date "%Y%m%d%H%M"  -- YYYYMMDDHHMM format
      if title ~= nil and title ~= "" then
        -- Transform title into valid file name suffix
        local suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        return timestamp .. "-" .. suffix
      else
        return timestamp
      end
    end,
    workspaces = {
      {
        name = "personal",
        path = "~/vaults/personal",
      },
      {
        name = "projects",
        path = "~/vaults/projects",
      },
      {
        name = "work",
        path = "~/vaults/work",
      },
    },
  },
  keys = {
    { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New Obsidian note" },
    { "<leader>oo", "<cmd>Obsidian search<cr>", desc = "Search Obsidian notes" },
    { "<leader>os", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch" },
    { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Show backlinks" },
    { "<leader>ot", "<cmd>Obsidian template<cr>", desc = "Insert template" },
    { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "Paste image" },
    { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Rename note" },
  },
}
