return {
  "saghen/blink.cmp",
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
        luasnip.config.setup({})

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
      documentation = { auto_show = true },
    },
    sources = {
      default = { "snippets", "lsp", "path", "buffer" },
    },
  },
  opts_extend = { "sources.default" },
}
