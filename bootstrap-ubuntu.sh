#!/bin/bash
set -eu

# shellcheck source=bootstrap-common.sh
source ./bootstrap-common.sh

sudo apt update
sudo apt install --yes \
    git curl `# basic tools` \
    zsh \
    fzf `# fuzzy search` \
    jq `# json processor` \
    htop \
    make `# nvim: needed by telescope-fzf-native build step` \
    xz-utils `# nvim: needed to extract neovim tarball` \
    ripgrep `# nvim: required by telescope live_grep` \
    fd-find `# nvim: required by telescope find_files (binary name: fdfind)` \
    ncdu `# ncurses du (find big files/dirs fast)`

# Neovim: apt version is too old on Ubuntu 24.04 / Debian 12; install from GitHub release.
install_neovim() {
    NVIM_VERSION="0.12.2"
    case "$(uname -m)" in
        x86_64)  NVIM_TARBALL="nvim-linux-x86_64.tar.gz" ;;
        aarch64) NVIM_TARBALL="nvim-linux-arm64.tar.gz"  ;;
        *)
            echo "Unsupported architecture: $(uname -m)" >&2
            return 1
            ;;
    esac
    NVIM_URL="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${NVIM_TARBALL}"
    NVIM_TMP="$(mktemp -d)"
    echo "Downloading neovim ${NVIM_VERSION} for $(uname -m)..."
    curl -fsSL "${NVIM_URL}" -o "${NVIM_TMP}/${NVIM_TARBALL}"
    sudo tar -C /usr/local --strip-components=1 -xzf "${NVIM_TMP}/${NVIM_TARBALL}"
    rm -rf "${NVIM_TMP}"
    echo "Neovim installed: $(nvim --version | head -1)"
}

if ! command -v nvim > /dev/null; then
    install_neovim
else
    echo "neovim already installed: $(nvim --version | head -1)"
fi

# fd-find installs as 'fdfind' on Debian/Ubuntu; create 'fd' symlink for telescope.
if command -v fdfind > /dev/null && ! command -v fd > /dev/null; then
    mkdir -p "${HOME}/.local/bin"
    ln -sf "$(command -v fdfind)" "${HOME}/.local/bin/fd"
fi

# Node: required by Mason for basedpyright, jsonls, yamlls LSP servers.
# Non-fatal: ruff (Python linting) works without node; LSP servers install on first interactive launch.
if ! command -v node > /dev/null; then
    echo "Installing nodejs via NodeSource..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - || true
    sudo apt install --yes nodejs || true
else
    echo "node already installed: $(node --version)"
fi

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
    # Fallback is mainly for Docker builds.
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

# Neovim
echo -e "\nConfiguring neovim..."

cp dotfiles/.ideavimrc ~/.ideavimrc

NVIM_CONFIG_DIR="${HOME}/.config/nvim"
if [ -d "${NVIM_CONFIG_DIR}" ]; then
    echo "Backing up existing nvim config to ${NVIM_CONFIG_DIR}.bak.${TS}"
    cp -r "${NVIM_CONFIG_DIR}" "${NVIM_CONFIG_DIR}.bak.${TS}"
    rm -rf "${NVIM_CONFIG_DIR}"
fi
mkdir -p "${HOME}/.config"
cp -r dotfiles/config/nvim "${NVIM_CONFIG_DIR}"

# Best-effort headless plugin presync; Mason LSP installs are skipped when headless.
echo "Pre-syncing neovim plugins (best-effort)..."
timeout 120 nvim --headless "+Lazy! sync" +qa 2>/dev/null || true


echo -e "\nAll done!"
echo "If this is the first time installing powerline10k, run 'p10k configure' to install Meslo Nerd font."
echo -e "\n\nRunning zsh now..."

zsh
