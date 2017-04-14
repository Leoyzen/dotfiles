#!/usr/bin/env bash

dir="$HOME/.dotfiles"
echo "Cloning Dotfiles"
git clone --recursive https://github.com/Leoyzen/dotfiles $dir

cd $dir
bash bin/bootstrap-new-system.sh

