#!/bin/bash
set -eu

# shellcheck source=bootstrap-common.sh
source ./bootstrap-common.sh

sudo apt update
sudo apt install --yes \
    git curl vim `# basic tools` \
    zsh \
    fzf `# fuzzy search` \
    jq `# json processor` \
    htop \
    build-essential cmake `# to compile Vim YouCompleteMe` \
    ncdu `# ncurses du (find big files/dirs fast)`

# Install Pyenv
# POD_NAME check is to automatically skip pyenv when inside a k8s pod (generally not needed there).
if [[ "${POD_NAME:=NONE}" == "NONE" ]] && [[ ! "${SKIP_PYENV:=0}" == "1"  ]] ; then
    sudo apt install --yes \
        `# the following are required for pyenv installs` \
        zlib1g-dev \
        libffi-dev \
        libssl-dev \
        `# the following are technically optional for pyenv installs, but not having them may cause problems:` \
        libbz2-dev \
        libsqlite3-dev \
        libncursesw5-dev \
        libreadline-dev \
        liblz-dev \
        lzma-dev \
        liblzma-dev

    echo "Checking for pyenv..."
    if [ ! -d "$HOME/.pyenv" ] ; then
        echo "Looks like pyenv is not installed, proceeding with install"
        curl https://pyenv.run | bash
    else
        echo "pyenv seems to be installed"
    fi

    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"

    pyenv install -s "${PY3_VERSION}"
    pyenv global "${PY3_VERSION}"

    pip install --upgrade pip
    pip install --upgrade pipx
else
    # Fallback is mainly for Docker builds, to allow compiling YouCompleteMe later.
    echo "Proceeding with fallback Python 3 install."
    sudo apt install --yes python3 python3-dev
fi


# Zsh
echo -e "\nChecking for oh my zsh..."

if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    echo "Could not find oh-my-zsh dir. Installing..."
    export RUNZSH=no  # by default, it runs zsh directly and this script does not continue
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "Installing oh-my-zsh plugins..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"
    git clone --depth=1 https://github.com/peterhurford/git-it-on.zsh "${HOME}/.oh-my-zsh/custom/plugins/git-it-on"
else
    echo "oh my zsh already installed, skipping"
fi

if [ -f ~/.zshrc ]; then
    ZSHRC_BAK="${HOME}/.zshrc.bak.${TS}"
    echo "Copying old ~/.zshrc to ${ZSHRC_BAK}"
    cp ~/.zshrc "${ZSHRC_BAK}"
fi
cp dotfiles/.zshrc ~/.zshrc
cp dotfiles/.p10k.zsh ~/.p10k.zsh

# Workaround for a very specific instance where the oh-my-zsh installation post-install chsh does not work:
if [[ "$(whoami)" == "jovyan" ]] ; then
    sudo chsh -s /bin/zsh jovyan
fi

# Vim
echo -e "\nConfiguring vim..."

if [ -f ~/.vimrc ]; then
    VIMRC_BAK="${HOME}/.vimrc.bak.${TS}"
    echo "Copying old ~/.vimrc to ${VIMRC_BAK}"
    cp ~/.vimrc "${VIMRC_BAK}"
fi

cp dotfiles/.vimrc ~/.vimrc
cp dotfiles/.ideavimrc ~/.ideavimrc

if [ ! -d "${HOME}/.vim/bundle" ]; then
    echo "Installing Vundle with YouCompleteMe"
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall
    pushd "${HOME}/.vim/bundle/YouCompleteMe"
    # Installation will fail if vim version is < 9.1:
    python3 install.py || true
    popd
else
    echo "Vundle already installed, skipping installation of Vundle and YouCompleteMe"
fi


echo -e "\nAll done!"
echo "If this is the first time installing powerline10k, run 'p10k configure' to install Meslo Nerd font."
echo -e "\n\nRunning zsh now..."

zsh
