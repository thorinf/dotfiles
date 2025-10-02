# Dotfiles

Bare git‑repo managing just the configs I actually use. macOS‑leaning but works fine on Linux.

## Quickstart

```bash
git clone --bare <repo-url> ~/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles checkout || echo 'Move conflicting files, then retry'
dotfiles config status.showUntrackedFiles no
# optional: global excludes
git config --global core.excludesfile "$HOME/.config/git/ignore"
```

Add the alias to `~/.zshrc`:
```bash
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```
First zsh/tmux session installs plugin managers (zinit, TPM). Open Neovim once so lazy.nvim synchronises plugins and Mason installs language tools.

## Install

- macOS (Homebrew): `brew install git zsh tmux neovim`
- Linux: install `git zsh tmux neovim` with your package manager
- Launch Neovim once; lazy.nvim installs plugins and Mason pulls required LSP/formatter binaries (`ruff`, `pyright`, `lua_ls`, `clangd`, `yamlls`, `jsonls`, `bashls`, etc.).

## What You Get

- Shell: zsh + zinit + Powerlevel10k, Ctrl+p/Ctrl+n history search, and trimmed history options.
- Tmux: Ctrl+a prefix, truecolor terminfo, OSC‑52 clipboard, TPM autoload.
- Terminal: Ghostty profile (optional), sensible defaults, no vendor lock‑in.
- Neovim: custom Lua config on lazy.nvim (blink.cmp, gitsigns, oil, telescope, treesitter, statusline). Ruff + Conform share the same resolver (prefers project `.venv` or `uv run ruff`).
- Consistency: `.editorconfig`, `.inputrc`, clang format/tidy defaults.

## Requirements

- git, zsh, tmux, neovim (0.9+)
- macOS: Homebrew recommended; Ghostty optional

## Policy

- No vendored plugin repos (tmux TPM, zinit, Neovim plugins).
- Track `~/.config/nvim/lazy-lock.json`; everything else under plugin/state dirs is ignored.
- Per‑dir `.gitignore` keeps caches and compiled artifacts out.

## Notes

- Host‑specific ignores live in `~/.dotfiles/info/exclude`.
- Terminfo: prefers `tmux-256color`, falls back to `screen-256color` if missing.

## How It Works

`~/.dotfiles` is a bare repo with `$HOME` as work tree, so only selected files are versioned.
