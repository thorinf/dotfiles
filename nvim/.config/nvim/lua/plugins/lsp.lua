local function prefer_local_ruff(start)
  local search_from = start
  if not search_from or search_from == "" then
    search_from = vim.loop.cwd()
  end

  -- Check for ruff.toml or uv project first
  local ruff_config = vim.fs.find({ "ruff.toml", "pyproject.toml" }, { upward = true, path = search_from })[1]
  if ruff_config and vim.fn.executable("uv") == 1 then
    return { cmd = "uv", args = { "run", "ruff" } }
  end

  -- Fallback to local venv
  local found = vim.fs.find({ ".venv/bin/ruff", "venv/bin/ruff" }, { upward = true, path = search_from })[1]
  if found and vim.fn.executable(found) == 1 then
    return { cmd = found }
  end

  return { cmd = "ruff" }
end
-- note: if formatting ever feels slow, cache the resolved path per root before returning

return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
      formatters_by_ft = {
        lua = { "stylua" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        python = { "ruff_fix", "ruff_format" },
        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
      },
      formatters = {
        ruff_fix = {
          command = function(ctx)
            local resolved = prefer_local_ruff(ctx.dirname)
            return resolved.cmd
          end,
          args = function(ctx)
            local resolved = prefer_local_ruff(ctx.dirname)
            local base_args = vim.deepcopy(require("conform.formatters.ruff_fix").args)
            if resolved.args then
              return vim.list_extend(vim.deepcopy(resolved.args), base_args)
            end
            return base_args
          end,
        },
        ruff_format = {
          command = function(ctx)
            local resolved = prefer_local_ruff(ctx.dirname)
            return resolved.cmd
          end,
          args = function(ctx)
            local resolved = prefer_local_ruff(ctx.dirname)
            local base_args = vim.deepcopy(require("conform.formatters.ruff_format").args)
            if resolved.args then
              return vim.list_extend(vim.deepcopy(resolved.args), base_args)
            end
            return base_args
          end,
        },
      },
    },
    config = function(_, opts)
      local conform = require("conform")

      conform.setup(opts)

      local function format()
        conform.format({ lsp_format = "fallback" })
      end

      local map_opts = { desc = "Format", silent = true }
      vim.keymap.set({ "n", "i" }, "<F12>", format, map_opts)

      vim.api.nvim_create_user_command("Format", format, { desc = "Format current buffer with LSP" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    keys = {
      { "<leader>lr", vim.cmd.LspRestart, desc = "LSP Restart" },
      { "<leader>li", vim.cmd.LspInfo, desc = "LSP Info" },
      {
        "<leader>lh",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
          vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
        end,
        desc = "Toggle Inlay Hints",
      },
    },
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      "mason-org/mason-lspconfig.nvim",
      {
        "aznhe21/actions-preview.nvim",
        event = "LspAttach",
        opts = {
          diff = {
            algorithm = "patience",
            ignore_whitespace = true,
          },
        },
      },
      {
        "rachartier/tiny-code-action.nvim",
        dependencies = {
          { "nvim-lua/plenary.nvim" },
        },
        event = "LspAttach",
        opts = {
          backend = "vim",
        },
      },
    },
    config = function()
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")

      vim.diagnostic.config({
        virtual_text = true,
        float = { border = "rounded" },
      })

      local border_opts = { border = "rounded" }
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, border_opts)
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, border_opts)

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink and blink.get_lsp_capabilities then
        capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities({}, false))
      end

      local function on_lsp_attach(_, bufnr)
        local function lsp_map(keys, func, desc)
          if desc then
            desc = "LSP: " .. desc
          end

          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc, silent = true })
        end

        lsp_map("K", vim.lsp.buf.hover, "Hover Documentation")
        lsp_map("gD", vim.lsp.buf.declaration, "Goto Declaration")
        lsp_map("gi", vim.lsp.buf.implementation, "Goto Implementation")
        lsp_map("gr", vim.lsp.buf.references, "Goto References")
        lsp_map("gd", vim.lsp.buf.definition, "Goto Definition")
        lsp_map("gt", vim.lsp.buf.type_definition, "Goto Type Definition")
        lsp_map("<leader>ca", require("tiny-code-action").code_action, "Code Action")
        lsp_map("<leader>cp", require("actions-preview").code_actions, "Code Action Preview")
        lsp_map("<leader>ss", vim.lsp.buf.document_symbol, "Search Symbols")
      end

      local servers = {
        clangd = {
          filetypes = { "c", "cpp", "proto" },
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
            "--offset-encoding=utf-16",
            "--query-driver=/usr/bin/clang*,/usr/bin/clang-*,/usr/bin/g++,/usr/bin/gcc,/usr/local/cuda/bin/*",
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = {
                globals = { "vim" },
              },
              runtime = { version = "LuaJIT" },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        bashls = {
          settings = { includeAllWorkspaceSymbols = true },
        },
        ruff = {
          on_new_config = function(new_config, root_dir)
            local resolved = prefer_local_ruff(root_dir)
            local cmd = { resolved.cmd }
            if resolved.args then
              vim.list_extend(cmd, resolved.args)
            end
            table.insert(cmd, "server")
            new_config.cmd = cmd
          end,
        },
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              schemaStore = { enable = true },
              validate = true,
            },
          },
        },
        jsonls = {},
        -- hls = {},
      }

      mason_lspconfig.setup({
        ensure_installed = { "clangd", "lua_ls", "bashls", "ruff", "basedpyright", "yamlls", "jsonls" },
        handlers = {
          function(server_name)
            local server_opts = vim.tbl_deep_extend("force", {
              capabilities = capabilities,
              on_attach = on_lsp_attach,
            }, servers[server_name] or {})

            lspconfig[server_name].setup(server_opts)
          end,
        },
      })
    end,
  },
}
