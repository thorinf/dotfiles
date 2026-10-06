#!/bin/zsh
set -eu

repo=${0:A:h:h}
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/completions/site-functions" "$scratch/completions/unrelated"
touch "$scratch/completions/unrelated/shared"
chmod g+w "$scratch/completions" "$scratch/completions/unrelated/shared"

fpath=("$scratch/completions/site-functions" $fpath)
autoload -Uz compaudit
_insecure=($(compaudit 2>/dev/null || true))
[[ ${#_insecure} -eq 1 && $_insecure[1] == "$scratch/completions" ]]
# Exercise the actual startup repair without loading prompt plugins or private aliases.
eval "$(sed -n '/^    for p in /,/^    done/p' "$repo/shell/.zshrc")"
[[ -z $(compaudit 2>/dev/null || true) ]]
[[ $(find "$scratch/completions/unrelated/shared" -perm -0020) != '' ]]
print 'shell permission checks passed'
