if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -t 0 ]]; then
  export GPG_TTY=$(tty)
fi

if [[ $- == *i* ]]; then
  ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
  if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  fi
  source "$ZINIT_HOME/zinit.zsh"

  zinit ice depth=1
  zinit light romkatv/powerlevel10k

  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-syntax-highlighting

  autoload -Uz compinit compaudit
  _zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-$ZSH_VERSION"
  _insecure=($(compaudit 2>/dev/null))
  if (( ${#_insecure[@]} )); then
    for p in "${_insecure[@]}"; do
      if [[ -O "$p" ]]; then
        chmod -R go-w "$p" 2>/dev/null || true
      fi
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

  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
  zstyle ':completion:*' menu no

  zinit cdreplay -q

  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi

bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

zle_highlight+=(paste:none)

HISTSIZE=100000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt extended_history
setopt inc_append_history
setopt share_history
setopt hist_reduce_blanks
setopt hist_verify
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Load shared aliases (tracked) and local aliases (untracked, machine-specific)
[[ -f ~/.aliases ]] && source ~/.aliases
[[ -f ~/.aliases.local ]] && source ~/.aliases.local

export NVM_DIR="$HOME/.nvm"
export NVM_SYMLINK_CURRENT=true
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  \. "$NVM_DIR/nvm.sh"
fi
if [[ -s "$NVM_DIR/bash_completion" ]]; then
  \. "$NVM_DIR/bash_completion"
fi
[[ -r "${HOME}/.ghcup/env" ]] && source "${HOME}/.ghcup/env"
