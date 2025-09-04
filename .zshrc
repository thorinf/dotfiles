# p10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# gpg setup
GPG_TTY=$(tty)
export GPG_TTY

if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export EDITOR=nvim
export PATH="$HOME/.npm-global/bin:$PATH"

# zinit, plugins, and completion (interactive shells only)
if [[ $- == *i* ]]; then
  ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
  if [ ! -d "$ZINIT_HOME" ]; then
     mkdir -p "$(dirname "$ZINIT_HOME")"
     git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  fi
  source "${ZINIT_HOME}/zinit.zsh"

  # theme
  zinit ice depth=1; zinit light romkatv/powerlevel10k

  # plugins
  zinit light zsh-users/zsh-syntax-highlighting
  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-autosuggestions

  # completions
  export ZSH_DISABLE_COMPFIX=true
  autoload -Uz compinit
  compinit -C -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-$ZSH_VERSION"

  zinit cdreplay -q

  # load p10k config
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi

# keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

zle_highlight+=(paste:none)

# history
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# aliases
# portable `ls` with colors
if command -v gls >/dev/null 2>&1; then
  alias ls='gls --color=auto'
elif [[ "$OSTYPE" == "darwin"* ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi
alias vim='nvim'
alias c='clear'
if command -v nvidia-smi >/dev/null 2>&1; then
  alias smi='watch -n 0.1 nvidia-smi'
fi

alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# macOS only aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias pomo='shortcuts run "Start Pomodoro"'
fi
