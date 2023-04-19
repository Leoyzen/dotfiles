#!/usr/bin/env bash

OS=`uname`

if [ $OS == 'Darwin' ];then
   # curl -O 'https://gist.githubusercontent.com/nicm/ea9cf3c93f22e0246ec858122d9abea1/raw/37ae29fc86e88b48dbc8a674478ad3e7a009f357/tmux-256color' \
     # && /usr/bin/tic -x tmux-256color || exit
   curl -L 'https://github.com/marcosnils/bin/releases/download/v0.8.0/bin_0.8.0_Darwin_x86_64' -o $HOME/.local/bin/bin && \
    chmod +x $HOME/.local/bin/bin
fi


