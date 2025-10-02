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
  opts = {
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
      completion = {
        menu = { auto_show = true },
      },
      sources = {},
    },
    sources = {
      default = { "snippets", "lsp", "path", "buffer" },
    },
  },
  opts_extend = { "sources.default" },
}
