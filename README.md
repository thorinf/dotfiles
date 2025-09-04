# Dotfiles

Bare-repo dotfiles. macOS‑first, no vendored plugins, fast bootstrap.

## Quickstart

```bash
git clone --bare <repo-url> ~/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles checkout || echo 'Move conflicting files, then retry'
dotfiles config status.showUntrackedFiles no
# optional: global excludes
git config --global core.excludesfile "$HOME/.config/git/ignore"
```

Add the alias to `~/.zshrc`. First zsh/tmux session auto‑installs plugin managers (zinit, TPM). Open Neovim once to let lazy.nvim sync.

## Requirements

- git, zsh, tmux, neovim (0.9+)
- macOS: Homebrew recommended; Ghostty optional

## What you get

- Shell: zsh + zinit + Powerlevel10k, Ctrl+p/Ctrl+n history search, sane history and completion.
- Tmux: Ctrl+a prefix, truecolor (`tmux-256color` + RGB), OSC‑52 clipboard, TPM auto‑install.
- Terminal: Ghostty with URL detection, 200k scrollback, 0.8 unfocused opacity, update checks.
- Neovim: NvChad (v2.5) via lazy.nvim; format‑on‑save with Conform (prefers project `.venv/bin/ruff`).
- Consistency: `.editorconfig` (indent/newlines) and `.inputrc` (readline vi‑mode + smarter history).
- Python tooling: `ruff` and BasedPyright defaults in `~/.config/{ruff,basedpyright}`.

## Policy

- Do not vendor plugin repos (tmux TPM, zinit, Neovim plugins).
- Track `~/.config/nvim/lazy-lock.json`; ignore the backup config’s lockfile.
- Per‑dir `.gitignore` keeps caches/artifacts out (TPM plugins, zinit, Emacs caches, etc.).

## Layout

- `~/.config/nvim/**`: current config (NvChad base) + `lazy-lock.json`.
- `~/.config/nvim.backup/**`: legacy config kept for reference (safe to delete if unused).
- `~/.config/tmux/tmux.conf`, `~/.config/ghostty/config`, `~/.zshrc`, `.editorconfig`, `.inputrc`, `.clang-*`.

## Notes

- Local‑only ignores: use `~/.dotfiles/info/exclude` for host‑specific patterns.
- Terminfo: prefers `tmux-256color`; falls back to `screen-256color`.

## How it works

`~/.dotfiles` is a bare repo with `$HOME` as work tree, so only selected files are versioned.
