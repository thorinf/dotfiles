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

  # plugins (order matters)
  # 1) completions  2) autosuggestions  3) syntax-highlighting (last)
  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-syntax-highlighting

  # completions (secure compinit)
  autoload -Uz compinit compaudit
  _zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-$ZSH_VERSION"

  # Attempt to fix insecure completion dirs owned by this user; else ignore them with a warning.
  _insecure=($(compaudit 2>/dev/null))
  if (( ${#_insecure[@]} )); then
    for p in "${_insecure[@]}"; do
      if [ -O "$p" ]; then chmod -R go-w "$p" 2>/dev/null || true; fi
    done
    _insecure=($(compaudit 2>/dev/null))
    if (( ${#_insecure[@]} )); then
      print -P '%F{yellow}zsh compinit: insecure completion dirs remain; disabling them:%f' >&2
      printf '  %s\n' "${_insecure[@]}" >&2
      compinit -i -d "$_zcompdump"
    else
      compinit -d "$_zcompdump"
    fi
  else
    compinit -d "$_zcompdump"
  fi

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
HISTSIZE=100000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
# robust, timestamped, low-dup history with immediate append
setopt extended_history
setopt inc_append_history
setopt sharehistory
setopt hist_reduce_blanks
setopt hist_verify
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
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
alias emacs='emacs -nw'
alias c='clear'
if command -v nvidia-smi >/dev/null 2>&1; then
  alias smi='watch -n 0.1 nvidia-smi'
fi

alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# macOS only aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias pomo='shortcuts run "Start Pomodoro"'
fi
