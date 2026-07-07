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
    build-essential `# nvim: C compiler needed by nvim-treesitter to build parsers` \
    xz-utils `# nvim: needed to extract neovim tarball` \
    ripgrep `# nvim: required by telescope live_grep` \
    fd-find `# nvim: required by telescope find_files (binary name: fdfind)` \
    ncdu `# ncurses du (find big files/dirs fast)` \
    bat `# cat with syntax highlighting (binary name: batcat on Debian/Ubuntu)` \
    shellcheck `# shell script linter` \
    tmux `# terminal multiplexer`

# Neovim: apt version is too old on Ubuntu 24.04 / Debian 12; install from GitHub release.
NVIM_VERSION="0.12.2"

# Prebuilt path: fast, used everywhere with a normal 4KB memory page size
# (x86_64, most aarch64, CI runners, Docker builds).
install_neovim_prebuilt() {
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
}

# Source path: the prebuilt release bundles a LuaJIT built for 4KB memory pages
# and segfaults on every invocation (incl. `nvim --version`) under a 16KB-page
# kernel, e.g. the Raspberry Pi 5 default arm64 kernel. Building from source
# picks up the system page size. Slow, only taken when 16KB pages are detected.
install_neovim_from_source() {
    echo "Building neovim ${NVIM_VERSION} from source (16KB memory pages detected)..."
    sudo apt install --yes ninja-build gettext cmake unzip
    NVIM_SRC="$(mktemp -d)"
    git clone --depth 1 --branch "v${NVIM_VERSION}" https://github.com/neovim/neovim "${NVIM_SRC}"
    make -C "${NVIM_SRC}" CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make -C "${NVIM_SRC}" install
    rm -rf "${NVIM_SRC}"
}

install_neovim() {
    if [ "$(getconf PAGESIZE)" = "16384" ]; then
        install_neovim_from_source
    else
        install_neovim_prebuilt
    fi
    echo "Neovim installed: $(nvim --version | head -1)"
}

if ! command -v nvim > /dev/null; then
    install_neovim
else
    echo "neovim already installed: $(nvim --version | head -1)"
fi

# tree-sitter CLI: required by nvim-treesitter (main branch) to build parsers.
# apt's version is too old; install the prebuilt binary from GitHub release.
#
# The prebuilt binaries are dynamically linked against glibc. From v0.25.0 they
# are built on a newer toolchain and require GLIBC_2.39, which Debian 12
# bookworm (glibc 2.36, e.g. Raspberry Pi OS) does not have:
#   tree-sitter: /lib/.../libc.so.6: version `GLIBC_2.39' not found
# v0.24.7 is the last release that links against an older glibc; it still runs
# on newer systems (glibc is backward compatible) and builds every parser we
# need. Pick it when the system glibc is too old for the latest CLI.
install_tree_sitter_cli() {
    local glibc
    glibc="$(getconf GNU_LIBC_VERSION 2>/dev/null | awk '{print $2}')"
    if [ -n "${glibc}" ] && [ "$(printf '%s\n2.39\n' "${glibc}" | sort -V | head -n1)" != "2.39" ]; then
        TS_VERSION="0.24.7"  # glibc < 2.39
    else
        TS_VERSION="0.26.9"  # glibc >= 2.39 (or undetectable)
    fi
    case "$(uname -m)" in
        x86_64)  TS_ASSET="tree-sitter-linux-x64.gz"   ;;
        aarch64) TS_ASSET="tree-sitter-linux-arm64.gz" ;;
        *)
            echo "Unsupported architecture for tree-sitter CLI: $(uname -m)" >&2
            return 1
            ;;
    esac
    TS_URL="https://github.com/tree-sitter/tree-sitter/releases/download/v${TS_VERSION}/${TS_ASSET}"
    mkdir -p "${HOME}/.local/bin"
    echo "Downloading tree-sitter CLI ${TS_VERSION} for $(uname -m)..."
    curl -fsSL "${TS_URL}" | gunzip > "${HOME}/.local/bin/tree-sitter"
    chmod +x "${HOME}/.local/bin/tree-sitter"
    echo "tree-sitter CLI installed: $("${HOME}/.local/bin/tree-sitter" --version)"
}

if ! command -v tree-sitter > /dev/null; then
    install_tree_sitter_cli
else
    echo "tree-sitter CLI already installed: $(tree-sitter --version)"
fi

# fd-find installs as 'fdfind' on Debian/Ubuntu; create 'fd' symlink for telescope.
if command -v fdfind > /dev/null && ! command -v fd > /dev/null; then
    mkdir -p "${HOME}/.local/bin"
    ln -sf "$(command -v fdfind)" "${HOME}/.local/bin/fd"
fi

# bat installs as 'batcat' on Debian/Ubuntu; create 'bat' symlink for consistency with mac.
if command -v batcat > /dev/null && ! command -v bat > /dev/null; then
    mkdir -p "${HOME}/.local/bin"
    ln -sf "$(command -v batcat)" "${HOME}/.local/bin/bat"
fi

# delta: git-delta is not packaged in apt; install .deb from GitHub release.
DELTA_VERSION="0.19.2"

install_delta() {
    case "$(uname -m)" in
        x86_64)  DELTA_DEB="git-delta_${DELTA_VERSION}_amd64.deb" ;;
        aarch64) DELTA_DEB="git-delta_${DELTA_VERSION}_arm64.deb" ;;
        *)
            echo "Unsupported architecture for delta: $(uname -m)" >&2
            return 1
            ;;
    esac
    DELTA_URL="https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/${DELTA_DEB}"
    DELTA_TMP="$(mktemp -d)"
    echo "Downloading delta ${DELTA_VERSION} for $(uname -m)..."
    curl -fsSL "${DELTA_URL}" -o "${DELTA_TMP}/${DELTA_DEB}"
    sudo dpkg -i "${DELTA_TMP}/${DELTA_DEB}"
    rm -rf "${DELTA_TMP}"
}

if ! command -v delta > /dev/null; then
    install_delta
else
    echo "delta already installed: $(delta --version)"
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
    pipx install pre-commit
else
    # Fallback is mainly for Docker builds.
    echo "Proceeding with fallback Python 3 install."
    sudo apt install --yes python3 python3-dev
fi


# Starship: cross-shell prompt (replaces powerlevel10k). Not reliably packaged in
# apt, so install via the official script. Install to ~/.local/bin (already on
# PATH, same as fd/bat/tree-sitter) so no sudo is needed - the default
# /usr/local/bin target requires a tty for sudo and fails in headless/CI builds.
if ! command -v starship > /dev/null; then
    echo "Installing starship..."
    mkdir -p "${HOME}/.local/bin"
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "${HOME}/.local/bin"
else
    echo "starship already installed: $(starship --version | head -1)"
fi


# Zsh
echo -e "\nChecking for oh my zsh..."

if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    echo "Could not find oh-my-zsh dir. Installing..."
    export RUNZSH=no  # by default, it runs zsh directly and this script does not continue
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "Installing oh-my-zsh plugins..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
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

# Starship prompt config:
mkdir -p "${HOME}/.config"
cp dotfiles/config/starship.toml ~/.config/starship.toml

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
# Put ~/.local/bin on PATH so nvim-treesitter finds the tree-sitter CLI during presync.
echo "Pre-syncing neovim plugins (best-effort)..."
PATH="${HOME}/.local/bin:${PATH}" timeout 120 nvim --headless "+Lazy! sync" +qa 2>/dev/null || true


# Configure delta as default git pager
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.dark true
git config --global merge.conflictStyle zdiff3

echo -e "\nAll done!"
echo "The prompt is now Starship (config: ~/.config/starship.toml). Requires a Nerd Font in your terminal."
echo -e "\n\nRunning zsh now..."

zsh
