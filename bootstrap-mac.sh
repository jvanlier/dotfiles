#!/usr/bin/env /bin/bash
set -eu

PY3_VERSION="3.8.6"
BASE_VENV="base-${PY3_VERSION}"

chsh -s /bin/zsh

echo "Installing pyenv..."
brew update
brew install pyenv pyenv-virtualenv

PYTHON_CONFIGURE_OPTS="--enable-framework" pyenv install -s $PY3_VERSION
set +e
pyenv virtualenvs|grep ${PY3_VERSION}/envs/${BASE_VENV}
set -e
if [ $? -neq 0 ]; then
    pyenv virtualenv $PY3_VERSION ${BASE_VENV}
    pyenv global ${BASE_VENV}
    pip install --upgrade pip pipx
    pipx install pipenv
else
    echo "virtualenv ${BASE_VENV} already installed"
fi

# TODO: skip step if already installed (it auto updates anyway)
echo "Installing oh my zsh..."
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

if [ -f ~/.zshrc ] ; then
    cp ~/.zshrc ~/.zshrc.bak
fi
ln -s ./.zshrc ~/.zshrc
ln -s ./.p10k.zsh ~/.p10k.zsh


echo "Configuring vim..."
ln -s ./.vimrc ~/.vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
cd ~/.vim/bundle/YouCompleteMe
python setup.py


echo "All done!. Remember to run 'p10k configure' to install Meslo Nerd font for powerline10k."
