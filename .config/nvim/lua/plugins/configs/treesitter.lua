return {
	ensure_installed = {
		"lua",
		"pkl",
		"rust",
		"gleam",
		"templ",
		"python",
		"c",
		"cpp",
		"haskell",
		"json",
		"jsonc",
		"yaml",
	},
	highlight = {
		enable = true,
		use_languagetree = true,
	},
	indent = { enable = true },
	autotag = {
		enable = true,
		enable_rename = true,
		enable_close = true,
		enable_close_on_slash = true,
		filetypes = { "html", "xml" },
	},
}
