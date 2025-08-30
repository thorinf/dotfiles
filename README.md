# Dotfiles

Personal dotfiles managed via a Git bare repo with `$HOME` as the work tree.

## Setup

```bash
git clone --bare <repo-url> ~/.dotfiles   # clone bare repo
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'  # helper alias
dotfiles checkout                          # write tracked files into $HOME
dotfiles config status.showUntrackedFiles no  # hide untracked $HOME noise
```

Add the alias to your shell config (e.g., `~/.zshrc`) if desired.

## Usage

```bash
dotfiles status                 # show changes
dotfiles add <path>             # stage a file
dotfiles commit -s -m "msg"     # commit with signoff
dotfiles push                   # push to origin
```

## Shortcuts

### Ghostty
- cmd+Left/Right/Up/Down: move between splits
- cmd+d / cmd+shift+d: split right / split down
- cmd+w: close surface (tab/window)

### Zsh
- Ctrl+p / Ctrl+n: search history backward/forward
- Alt+w: kill region
- Powerlevel10k theme; zinit manages plugins (syntax, completions, autosuggest)

### TMUX
- Prefix: Ctrl+a (send-prefix on Ctrl+a)
- Panes: h/j/k/l or Alt+Arrow; split: `-`/`|` or `"`/`%`; new window: `c`
- Windows: Shift+Left/Right or Alt+h/Alt+l
- Copy mode (vi): `y` copy selection, `Y` copy to EOL (OSC 52 clipboard)
- Display: truecolor enabled (`tmux-256color` + RGB overrides)

### Neovim
- Leader: Space
- Telescope: `<leader>ff` files, `fb` buffers, `fg` live grep, `fh` help, `fn` file browser
- LSP/completion via mason + cmp; treesitter for syntax; which-key/lualine UI

### Emacs
- Focused on Org mode (with evil keybindings); minimal elsewhere
- Org indentation/visual tweaks; evil-org for better navigation

## How it works

A Git bare repository lives at `~/.dotfiles` and treats `$HOME` as the working tree. This tracks selected files without turning your entire home directory into a Git repo.

