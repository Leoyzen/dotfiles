#!/usr/bin/env bash

dotfiles="$HOME/.dotfiles"
fish_conf="$HOME/.config/fish/conf.d"

if [[ -d "$dotfiles" ]]; then
  echo "Symlinking dotfiles from $dotfiles"
else
  echo "$dotfiles does not exist"
  exit 1
fi

link() {
  from="$1"
  to="$2"
  echo "Linking '$from' to '$to'"
  rm -f "$to"
  ln -s "$from" "$to"
}

for location in $(find home -name '.*.sh'); do
  file="${location##*/}"
  file="${file%.sh}"
  link "$dotfiles/$location" "$HOME/$file"
done

# Link Fish Config
for location in $(find home -name '*.fish'); do
  file="${location##*/}"
  echo $location, $file
  link "$dotfiles/$location" "$fish_conf/$file"
done
