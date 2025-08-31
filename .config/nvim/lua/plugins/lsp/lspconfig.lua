return {
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- Resolve project Python interpreter from .venv when present
			local util = require("lspconfig.util")
			local function project_python(root)
				local p = root .. "/.venv/bin/python"
				return (vim.fn.executable(p) == 1) and p or "python3"
			end

			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
							disable = { "different-requires" },
						},
					},
				},
			})

			lspconfig.rust_analyzer.setup({})

			-- (Go disabled by user)

			lspconfig.tailwindcss.setup({
				settings = {
					includeLanguages = {
						templ = "html",
					},
				},
			})

			lspconfig.templ.setup({})

			-- C/C++/CUDA: clangd
			local clang_capabilities = vim.tbl_deep_extend("force", capabilities, { offsetEncoding = { "utf-16" } })
			lspconfig.clangd.setup({
				capabilities = clang_capabilities,
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=never",
					"--query-driver=/usr/bin/clang*,/usr/bin/clang-*,/usr/bin/g++,/usr/bin/gcc,/usr/local/cuda/bin/*",
				},
			})

			-- Haskell: HLS
			lspconfig.hls.setup({
				capabilities = capabilities,
			})


			-- Python: Ruff (built-in LSP) for linting/code actions + BasedPyright for types
			local ruff_fmt_group = vim.api.nvim_create_augroup("RuffFormatOnSave", { clear = true })
			lspconfig.ruff.setup({
				-- Run Ruff LSP through uv so it picks the project env
				cmd = { "uv", "run", "ruff", "server" },
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						vim.api.nvim_clear_autocmds({ group = ruff_fmt_group, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = ruff_fmt_group,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({ bufnr = bufnr, id = client.id })
							end,
						})
					end
				end,
			})

			-- Ensure basedpyright works even if lspconfig is older
			local configs = require('lspconfig.configs')
			if not configs.basedpyright then
				configs.basedpyright = {
					default_config = {
						cmd = { 'uv', 'run', 'basedpyright-langserver', '--stdio' },
						filetypes = { 'python' },
						root_dir = util.root_pattern('pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git'),
						settings = {},
					},
				}
			end
			lspconfig.basedpyright.setup({
				capabilities = capabilities,
				cmd = { 'uv', 'run', 'basedpyright-langserver', '--stdio' },
				settings = { python = {} },
				on_new_config = function(new_config, root_dir)
					new_config.settings.python.pythonPath = project_python(root_dir)
				end,
			})
		end,
	},
}
