#!/usr/bin/env /bin/bash
set -eu

PY3_VERSION="3.8.6"
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
set +e
set +x
pyenv virtualenvs|grep ${PY3_VERSION}/envs/${BASE_VENV}
set -e
if [ $? -ne 0 ]; then
    pyenv virtualenv $PY3_VERSION ${BASE_VENV}
    pyenv global ${BASE_VENV}
    pip install --upgrade pip
    pip install pipx
else
    echo "virtualenv ${BASE_VENV} already installed, skipping"
fi

# Zsh
echo "Checking for oh my zsh..."

if [ ! -d ${HOME}/.oh-my-zsh ]; then
    echo "Could not find oh-my-zsh dir. Will chsh to zsh first and then install oh-my-zsh."
    chsh -s /bin/zsh
    echo "Installing oh my zsh..."
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
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
echo "Configuring vim..."

if [ ! -d ${HOME}/.vim/bundle ]; then
    echo "Installing Vundle with YouCompleteMe"
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall
    OLD_PWD=$(pwd)
    cd ~/.vim/bundle/YouCompleteMe
    python setup.py
    cd $OLD_PWD
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

echo "All done! If this is the first time installing powerline10k, run 'p10k configure' to install Meslo Nerd font."
