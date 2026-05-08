# Dotfiles

Requires **Neovim 0.12+** (uses `vim.pack` and `vim.lsp.config`). On
Ubuntu/Debian the default `apt install neovim` may ship an older version —
use the [Neovim PPA](https://github.com/neovim/neovim/blob/master/INSTALL.md#install-from-package)
or build from source if so.

```bash
# install dependencies
make brew    # macOS
make apt     # Ubuntu/Debian

# stow dotfiles (restows repo versions into $HOME)
make install

# first-time adoption of existing dotfiles into the repo
make adopt

# or manually:
stow -t ~ --adopt editor emacs ghostty lint nvim ruff shell starship tmux
stow -t ~ --restow editor emacs ghostty lint nvim ruff shell starship tmux
git status  # review and commit the adopted files
```
