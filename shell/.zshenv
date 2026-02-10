export EDITOR=nvim
export VISUAL=nvim

export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:${PATH:-}"

if [[ -d "$HOME/.nvm/versions/node/current/bin" ]]; then
  export PATH="$HOME/.nvm/versions/node/current/bin:$PATH"
fi
. "$HOME/.cargo/env"
