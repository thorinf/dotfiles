local function prefer_local_ruff(start)
  local search_from = start
  if not search_from or search_from == "" then
    search_from = vim.uv.cwd()
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
        toml = { "taplo" },
        cs = { "csharpier" },
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
      {
        "<leader>lr",
        function()
          for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
            vim.lsp.stop_client(client.id)
          end
          vim.cmd("edit")
        end,
        desc = "LSP Restart",
      },
      { "<leader>li", "<cmd>checkhealth vim.lsp<CR>", desc = "LSP Info" },
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
      {
        "mason-org/mason.nvim",
        opts = {
          -- Add Crashdummyy's registry for Roslyn (and other servers not in the core registry).
          registries = {
            "github:mason-org/mason-registry",
            "github:Crashdummyy/mason-registry",
          },
        },
      },
      "mason-org/mason-lspconfig.nvim",
      {
        "aznhe21/actions-preview.nvim",
        event = "LspAttach",
        opts = {
          diff = { algorithm = "patience", ignore_whitespace = true },
        },
      },
      {
        "rachartier/tiny-code-action.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "LspAttach",
        opts = { backend = "vim" },
      },
    },
    config = function()
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          prefix = "●",
          severity = { min = vim.diagnostic.severity.WARN },
        },
        virtual_lines = false,
        float = { border = "rounded" },
      })

      -- Rounded border on all LSP floating windows (modern replacement for vim.lsp.with).
      local orig_open_floating = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or "rounded"
        return orig_open_floating(contents, syntax, opts, ...)
      end

      -- Buffer-local keymaps when an LSP attaches (replaces per-server on_attach).
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local function map(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc, silent = true })
          end
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("gi", vim.lsp.buf.implementation, "Goto Implementation")
          map("gr", vim.lsp.buf.references, "Goto References")
          map("gd", vim.lsp.buf.definition, "Goto Definition")
          map("gt", vim.lsp.buf.type_definition, "Goto Type Definition")
          map("<leader>ca", require("tiny-code-action").code_action, "Code Action")
          map("<leader>cp", require("actions-preview").code_actions, "Code Action Preview")
          map("<leader>ss", vim.lsp.buf.document_symbol, "Search Symbols")
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink and blink.get_lsp_capabilities then
        capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities({}, false))
      end

      -- Per-server settings. Applied via vim.lsp.config (nvim 0.11+ API);
      -- mason-lspconfig will auto-enable each server in ensure_installed.
      local servers = {
        clangd = {
          filetypes = { "c", "cpp", "cuda", "proto" },
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
              completion = { callSnippet = "Replace" },
              diagnostics = { globals = { "vim" } },
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
          -- Pick up project-local ruff (uv / venv) when the server initializes.
          before_init = function(_, config)
            local root = config.root_dir or vim.uv.cwd()
            local resolved = prefer_local_ruff(root)
            local cmd = { resolved.cmd }
            if resolved.args then
              vim.list_extend(cmd, resolved.args)
            end
            table.insert(cmd, "server")
            config.cmd = cmd
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
        taplo = {},
        -- C# is handled separately via seblyng/roslyn.nvim (see plugin spec below).
        -- Install the server once via :MasonInstall roslyn (Crashdummyy's registry).
      }

      for name, opts in pairs(servers) do
        opts.capabilities = vim.tbl_deep_extend("force", capabilities, opts.capabilities or {})
        vim.lsp.config(name, opts)
      end

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = true,
      })
    end,
  },
  {
    -- Modern C# LSP via the Roslyn server (replaces deprecated omnisharp).
    -- Install the server once: `:MasonInstall roslyn` (uses the Crashdummyy mason registry).
    "seblyng/roslyn.nvim",
    ft = "cs",
    opts = {},
  },
}
