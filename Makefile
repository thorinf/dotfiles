.PHONY: install adopt uninstall restow brew apt

PACKAGES := editor emacs ghostty lint nvim ruff shell tmux
STOW ?= stow
STOW_TARGET ?= $(HOME)

install:
	$(STOW) -t $(STOW_TARGET) --restow $(PACKAGES)

adopt:
	$(STOW) -t $(STOW_TARGET) --adopt $(PACKAGES)
	$(STOW) -t $(STOW_TARGET) --restow $(PACKAGES)
	@printf 'Review and commit the adopted files before continuing.\n'

uninstall:
	$(STOW) -t $(STOW_TARGET) -D $(PACKAGES)

restow:
	$(STOW) -t $(STOW_TARGET) --restow $(PACKAGES)

brew:
	brew install stow neovim tmux ripgrep btop node

apt:
	sudo apt update && sudo apt install -y stow neovim tmux zsh ripgrep btop
