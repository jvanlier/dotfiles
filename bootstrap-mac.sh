#!/usr/bin/env /bin/bash
set -eu

PY3_VERSION="3.10.6"
BASE_VENV="base-${PY3_VERSION}"
TS=$(date +'%Y-%m-%dT%H-%M-%S')


# Homebrew
echo "Checking for Homebrew..."
if ! command -v brew > /dev/null ; then
    echo "Looks like homebrew is not installed, proceeding with install."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew seems to be installed, trying to update.."
    brew update
fi


# Various Homebrew-installable tools.
brew install \
        vim `# default vim has no Python3 support, brew verson does` \
	jq \
	gnu-sed `# default sed differs from Linux equivalent` \
	htop \
	rectangle `# replacement for ShiftIt` \
	cmake `# to compile Vim YouCompleteMe, among other things` \ 
	postgresql `# requirement for pip install psycopg2-binary` \
	libjpeg `# requirement for pip install pillow` \
	hadolint `# linter for Dockerfiles` \
	dive `# useful tool to inspect docker images` \
	ncdu `# ncurses du (find big files/dirs fast)` \
        kubectx `# kubectx and kubens, simplify k8s access`
brew install --cask \
	google-cloud-sdk

# Pyenv
echo "Checking for pyenv..."
if ! command -v pyenv > /dev/null ; then
    echo "Looks like pyenv is not installed, proceeding with install through brew."
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

if [ -f ~/.vimrc ]; then
    VIMRC_BAK="${HOME}/.vimrc.bak.${TS}"
    echo "Copying old ~/.vimrc to $VIMRC_BAK"
    cp ~/.vimrc $VIMRC_BAK
fi

cp .vimrc ~/.vimrc
cp .ideavimrc ~/.ideavimrc

if [ ! -d ${HOME}/.vim/bundle ]; then
    echo "Installing Vundle with YouCompleteMe"
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    /opt/homebrew/bin/vim +PluginInstall +qall
    pushd ${HOME}/.vim/bundle/YouCompleteMe
    python install.py
    popd
else
    echo "Vundle already installed, skipping installation of Vundle and YouCompleteMe"
fi

# Enable repeating keys (disable the popup to select diacritics etc):
defaults write -g ApplePressAndHoldEnabled -bool false

echo -e "\nAll done!"
echo "If this is the first time installing powerline10k, run 'p10k configure' to install Meslo Nerd font."
echo -e "You will also have to reboot to enable repeating keys.\n\nRunning zsh now..."

zsh

