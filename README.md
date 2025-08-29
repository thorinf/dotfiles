# Dotfiles

This repository manages my dotfiles using the bare repository method.

## Setup

Clone and set up the dotfiles:

```bash
git clone --bare https://github.com/thorinf/dotfiles.git ~/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles checkout
```

Add the alias to your shell config to make it permanent:

```bash
echo "alias dotfiles='git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'" >> ~/.bashrc
```

## Usage

Manage dotfiles with the `dotfiles` alias:

```bash
# Check status
dotfiles status

# Add files
dotfiles add .bashrc .vimrc

# Commit changes
dotfiles commit -m "update shell config"

# Push to remote
dotfiles push
```

## How it works

This setup uses a bare git repository stored in `~/.dotfiles/` with your home directory as the working tree. This allows you to track dotfiles throughout your home directory without making your entire home directory a git repository.