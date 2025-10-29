return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "v1.*",
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      build = "make install_jsregexp",
      opts = {
        region_check_events = "InsertEnter",
        delete_check_events = "InsertLeave",
      },
      config = function(_, opts)
        local luasnip = require("luasnip")
        luasnip.config.set_config(opts)

        local loaders = require("luasnip.loaders.from_vscode")
        loaders.lazy_load()
        loaders.load({
          paths = { vim.fs.normalize(vim.fn.stdpath("config") .. "/snippets") },
        })
      end,
    },
  },
  opts = function()
    local disabled_ft = {
      "TelescopePrompt",
      "grug-far",
    }

    local function is_enabled()
      return not vim.tbl_contains(disabled_ft, vim.bo.filetype)
        and vim.b.completion ~= false
        and vim.bo.buftype ~= "prompt"
    end

    return {
      enabled = is_enabled,
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
      },
      snippets = { preset = "luasnip" },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        menu = {
          scrollbar = false,
          auto_show = is_enabled,
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
              { "", "DiagnosticHint" },
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
        completion = {
          menu = { auto_show = true },
        },
        sources = {},
      },
      sources = {
        default = { "lsp", "snippets", "path", "buffer" },
      },
    }
  end,
  opts_extend = { "sources.default" },
}
