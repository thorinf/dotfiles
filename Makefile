.PHONY: install uninstall restow brew apt

PACKAGES := editor emacs ghostty lint nvim ruff shell tmux

install:
	stow $(PACKAGES)

uninstall:
	stow -D $(PACKAGES)

restow:
	stow -R $(PACKAGES)

brew:
	brew install stow neovim tmux ripgrep

apt:
	sudo apt update && sudo apt install -y stow neovim tmux zsh ripgrep
