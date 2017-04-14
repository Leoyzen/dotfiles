#!/usr/bin/env bash
# A simple script for setting up dev environment.

dev="$HOME/.dotfiles"
pushd .
mkdir -p $dev
cd $dev


pub=$HOME/.ssh/id_rsa.pub
echo 'Checking for SSH key, generating one if it does not exist...'
  [[ -f $pub ]] || ssh-keygen -t rsa

# echo 'Copying public key to clipboard. Paste it into your Github account...'
  # [[ -f $pub ]] && cat $pub | pbcopy
  # open 'https://github.com/account/ssh'

# If we on OS X, install homebrew and tweak system a bit.
if [[ `uname` == 'Darwin' ]]; then
  which -s brew
  if [[ $? != 0 ]]; then
    echo 'Installing Homebrew...'
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      brew update
      brew install htop ruby grc fish tmux macvim cmake git
  fi

  # echo 'Tweaking OS X...'
    # source 'etc/osx.sh'

elif [[ `uname` == 'Linux' ]];then
    which -s brew
    if [[ $? != 0 ]];then
        echo 'Installing Linux Brew...'
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
        brew update
        brew install htop ruby grc fish tmux vim cmake git
    fi
fi

pyenv_dir=$HOME/.pyenv
if [[ ! -d $pyenv_dir ]];then
    echo "Pyenv not found, Installing..."
    curl -L "https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer" | bash
fi

if [[ ! -d $HOME/.local/share/omf ]];then
    echo "Installing Oh My Fish and Fisherman"
    curl -L https://get.oh-my.fish | fish
    curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
fi

echo 'Symlinking config files...'
  source 'bin/symlink-dotfiles.sh'


