#!/bin/sh
set -eu

repo=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
scratch=$(mktemp -d)
socket=$scratch/tmux.sock
trap 'tmux -S "$socket" kill-server 2>/dev/null || true; rm -rf "$scratch"' EXIT

# shellcheck disable=SC2016 # The directory name must contain literal shell syntax.
name='$(touch EXECUTED)'
mkdir -p "$scratch/$name/child"
tmux -S "$socket" -f /dev/null new-session -d -s review -c "$scratch/$name/child" /bin/sh
tmux -S "$socket" source-file "$repo/tmux/.config/tmux/status.conf"
for option in window-status-current-format window-status-format; do
  rendered=$(tmux -S "$socket" display-message -p "#{E:$option}")
  case "$rendered" in
    "#[fg=]$name/child#[default]") ;;
    *) printf 'Unexpected status: %s\n' "$rendered" >&2; exit 1 ;;
  esac
done
test ! -e "$scratch/$name/child/EXECUTED"
printf 'tmux status checks passed\n'
