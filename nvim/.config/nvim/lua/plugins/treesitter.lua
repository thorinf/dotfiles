-- Native treesitter highlighting via nvim 0.12+ APIs.
-- Plugin removed (nvim-treesitter master archived 2026-04 and broken on 0.12).
-- Parsers + non-bundled queries live in ~/.local/share/nvim/site/.
-- To install a new parser: build the .so via tree-sitter-cli and drop it in the parser dir.

local supported = {
  "lua",
  "vim",
  "vimdoc",
  "query",
  "c",
  "cpp",
  "cuda",
  "python",
  "markdown",
  "markdown_inline",
  "toml",
  "yaml",
  "json",
  "bash",
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = supported,
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

return {}
