#!/usr/bin/env /bin/bash
set -exu

chsh -s /bin/zsh

echo "Installing pyenv..."
brew update
brew install pyenv pyenv-virtualenv

# TODO:  
# - install Python 3.8 in Framework mode if not yet installed
# - create "base" virtualenv if not exists
# - pyenv global base
# - install pipx

echo "Installing oh my zsh..."
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions



ln -s ./.zshrc ~/.zshrc
ln -s ./.p10k.zsh ~/.p10k.zsh
ln -s ./.vimrc ~/.vimrc
