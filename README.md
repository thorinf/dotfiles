# Dotfiles

Bare‑repo dotfiles. macOS‑first, no vendored plugins, fast bootstrap.

## Quickstart

```bash
git clone --bare <repo-url> ~/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles checkout || echo 'Move conflicting files, then retry'
dotfiles config status.showUntrackedFiles no
# optional: global excludes
git config --global core.excludesfile "$HOME/.config/git/ignore"
```

Add the alias to `~/.zshrc`. First zsh/tmux session auto‑installs plugin managers (zinit, TPM). Open Neovim once to let lazy.nvim sync and let Mason install tools.

## Install

- macOS (Homebrew): `brew install git zsh tmux neovim`
- Linux: use your package manager to install `git zsh tmux neovim`
- Open Neovim once: plugins sync; tools auto‑install via mason‑tool‑installer

Mason tools ensured: `ruff`, `pyright`, `lua-language-server`, `rust-analyzer`, `tailwindcss-language-server`, `json-lsp`, `yaml-language-server`, `clangd`, `haskell-language-server`, `templ`.

## What You Get

- Shell: zsh + zinit + Powerlevel10k, Ctrl+p/Ctrl+n history search, sane history and completion.
- Tmux: Ctrl+a prefix, truecolor (`tmux-256color` + RGB), OSC‑52 clipboard, TPM auto‑install.
- Terminal: Ghostty settings (optional), large scrollback, update checks.
- Neovim: NvChad (v2.5) via lazy.nvim; Ruff for lint+format, Pyright for types. Conform and LSP use the same Ruff binary (prefers project `.venv/bin/ruff`).
- Consistency: `.editorconfig` and `.inputrc`.

## Requirements

- git, zsh, tmux, neovim (0.9+)
- macOS: Homebrew recommended; Ghostty optional

## Policy

- No vendored plugin repos (tmux TPM, zinit, Neovim plugins).
- Track `~/.config/nvim/lazy-lock.json`; ignore backup lockfiles.
- Per‑dir `.gitignore` keeps caches/artifacts out (TPM plugins, zinit, Emacs caches, etc.).

## Notes

- Local‑only ignores: use `~/.dotfiles/info/exclude` for host‑specific patterns.
- Terminfo: prefers `tmux-256color`; falls back to `screen-256color`.

## How It Works

`~/.dotfiles` is a bare repo with `$HOME` as work tree, so only selected files are versioned.
