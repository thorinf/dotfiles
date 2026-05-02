-- LuaSnip setup (loaded lazily on InsertEnter to keep startup fast)
vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    local luasnip = require("luasnip")
    luasnip.config.set_config({
      region_check_events = "InsertEnter",
      delete_check_events = "InsertLeave",
    })
    local loaders = require("luasnip.loaders.from_vscode")
    loaders.lazy_load()
    loaders.lazy_load({
      paths = { vim.fs.normalize(vim.fn.stdpath("config") .. "/snippets") },
    })

    -- blink.cmp setup
    local disabled_ft = { "TelescopePrompt", "grug-far" }
    local function is_enabled()
      return not vim.tbl_contains(disabled_ft, vim.bo.filetype)
        and vim.b.completion ~= false
        and vim.bo.buftype ~= "prompt"
    end

    require("blink.cmp").setup({
      enabled = is_enabled,
      keymap = {
        preset = "enter",
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.snippet_forward()
            elseif cmp.is_visible() then
              return cmp.select_and_accept()
            end
          end,
          "fallback",
        },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      },
      snippets = { preset = "luasnip" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        menu = {
          scrollbar = false,
          auto_show = function()
            return is_enabled()
          end,
          border = {
            { "󱐋", "WarningMsg" },
            "─",
            "╮",
            "│",
            "╯",
            "─",
            "╰",
            "│",
          },
        },
        documentation = {
          auto_show = true,
          window = {
            border = {
              { "", "DiagnosticHint" },
              "─",
              "╮",
              "│",
              "╯",
              "─",
              "╰",
              "│",
            },
          },
        },
      },
      cmdline = {
        completion = { menu = { auto_show = true } },
      },
      sources = {
        default = { "lsp", "snippets", "path", "buffer" },
      },
    })
  end,
})
