.PHONY: install adopt uninstall restow brew apt nvim-linux starship-linux

PACKAGES := editor emacs ghostty lint nvim ruff shell starship tmux
STOW ?= stow
STOW_TARGET ?= $(HOME)
NVIM_UNAME := $(shell uname -m)
NVIM_ARCH := $(if $(filter arm64 aarch64,$(NVIM_UNAME)),arm64,x86_64)
NVIM_TARBALL := nvim-linux-$(NVIM_ARCH).tar.gz
NVIM_PREFIX ?= $(HOME)/.local/opt
LOCAL_BIN ?= $(HOME)/.local/bin

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
	brew install stow neovim tmux ripgrep btop node ccache fzf starship \
		pre-commit stylua shfmt shellcheck gitleaks clang-format prettier

apt:
	sudo apt update && sudo apt install -y stow tmux zsh ripgrep btop ccache fzf \
		pre-commit shfmt shellcheck clang-format curl tar gzip nodejs npm \
		git build-essential
	$(MAKE) nvim-linux
	$(MAKE) starship-linux
	mkdir -p $(HOME)/.npm-global
	npm config set prefix $(HOME)/.npm-global
	npm install -g prettier
	# csharpier (optional, for C# format-on-save): `dotnet tool install -g csharpier`

nvim-linux:
	mkdir -p $(LOCAL_BIN) $(NVIM_PREFIX)
	curl -fsSL -o /tmp/$(NVIM_TARBALL) \
		https://github.com/neovim/neovim/releases/latest/download/$(NVIM_TARBALL)
	rm -rf $(NVIM_PREFIX)/nvim-linux-$(NVIM_ARCH)
	tar -C $(NVIM_PREFIX) -xzf /tmp/$(NVIM_TARBALL)
	ln -sf $(NVIM_PREFIX)/nvim-linux-$(NVIM_ARCH)/bin/nvim $(LOCAL_BIN)/nvim
	$(LOCAL_BIN)/nvim --version | sed -n '1p'

starship-linux:
	mkdir -p $(LOCAL_BIN)
	curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b $(LOCAL_BIN)
