if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

typeset -U path
path=(
  "$HOME/.local/bin"
  "$HOME/.npm-global/bin"
  $path
)

export PATH
