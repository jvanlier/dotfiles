#!/usr/bin/env /bin/bash
set -eu

PY3_VERSION="3.10.4"
BASE_VENV="base-${PY3_VERSION}"
TS=$(date +'%Y-%m-%dT%H-%M-%S')

# Pyenv
echo "Checking for pyenv..."
if ! command -v pyenv > /dev/null ; then
    echo "Looks like pyenv is not installed, proceeding with install through brew."
    brew update
    brew install pyenv pyenv-virtualenv
else
    echo "pyenv seems to be installed"
fi

PYTHON_CONFIGURE_OPTS="--enable-framework" pyenv install -s $PY3_VERSION
pyenv global $PY3_VERSION
pip install --upgrade pip
pip install --upgrade pipx

# Zsh
echo -e "\nChecking for oh my zsh..."

if [ ! -d ${HOME}/.oh-my-zsh ]; then
    echo "Could not find oh-my-zsh dir. Installing..."
    export CHSH=no  # chsh is no longer needed since MacOS Catalina
    export RUNZSH=no  # by default, it runs zsh directly and this script does not continue 
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "Installing oh-my-zsh plugins..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    echo "oh my zsh already installed, skipping"
fi

if [ -f ~/.zshrc ]; then
    ZSHRC_BAK="${HOME}/.zshrc.bak.${TS}"
    echo "Copying old ~/.zshrc to $ZSHRC_BAK"
    cp ~/.zshrc $ZSHRC_BAK
fi
cp .zshrc ~/.zshrc
cp .p10k.zsh ~/.p10k.zsh

# Vim
echo -e "\nConfiguring vim..."

if [ ! -d ${HOME}/.vim/bundle ]; then
    brew install vim  # default vim has no Python3 support, brew verson does
    source ~/.zshrc  # reload PATH to pick up brew version
    echo "Installing Vundle with YouCompleteMe"
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall
    brew install cmake  # needed to compile YCM
    pushd ${HOME}/.vim/bundle/YouCompleteMe
    python install.py
    popd
else
    echo "Vundle already installed, skipping installation of Vundle and YouCompleteMe"
fi

if [ -f ~/.vimrc ]; then
    VIMRC_BAK="${HOME}/.vimrc.bak.${TS}"
    echo "Copying old ~/.vimrc to $VIMRC_BAK"
    cp ~/.vimrc $VIMRC_BAK
fi

cp .vimrc ~/.vimrc
cp .ideavimrc ~/.ideavimrc

echo -e "\nAll done! Running zsh now."
echo "If this is the first time installing powerline10k, run 'p10k configure' to install Meslo Nerd font."

zsh

