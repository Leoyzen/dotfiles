#!/usr/bin/env bash
PREINSTALL_PACKAGES=(fish tmux vim neovim git-fixup git-delta rye uv rustup-init bat ripgrep fd eza fzf git-lfs htop ncdu node micromamba starship)
FISH_PLUGINS=(plttn/fish-eza oh-my-fish/plugin-extract jhillyerd/plugin-git edc/bass patrickf1/fzf.fish)
if ! command -v brew &> /dev/null;
then
    git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install || exit 0
    /bin/bash brew-install/install.sh || exit 0
    rm -rf brew-install || exit 0

    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" || exit 0
    test -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile || exit 0
    test -r ~/.profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile || exit 0
    test -r ~/.zprofile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.zprofile || exit 0

     /home/linuxbrew/.linuxbrew/bin/brew install "${PREINSTALL_PACKAGES[@]}"

    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" || exit 0
    fish -c "fisher install ${FISH_PLUGINS[*]}" || exit 0
fi


exec "$@"