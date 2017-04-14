#!/usr/bin/env bash

dir="$HOME/.dotfiles"
"Cloning Dotfiles"
git clone --recursive git@github.com:Leoyzen/dotfiles.git $dir

cd $dir
bash bin/bootstrap-new-system.sh

