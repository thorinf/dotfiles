# Dotfiles

```bash
# install dependencies
make brew    # macOS
make apt     # Ubuntu/Debian

# stow dotfiles (restows repo versions into $HOME)
make install

# first-time adoption of existing dotfiles into the repo
make adopt

# or manually:
stow -t ~ --adopt editor emacs ghostty lint nvim ruff shell tmux
stow -t ~ --restow editor emacs ghostty lint nvim ruff shell tmux
git status  # review and commit the adopted files
```
