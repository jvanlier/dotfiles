#!/bin/bash
set -eu

# shellcheck source=bootstrap-common.sh
source bootstrap-common.sh

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
        neovim `# replaces vim` \
        fzf `# fuzzy search` \
	jq `# json processor` \
	gnu-sed `# default sed differs from Linux equivalent` \
	htop \
	rectangle `# replacement for ShiftIt` \
	postgresql `# requirement for pip install psycopg2-binary` \
	libjpeg `# requirement for pip install pillow` \
	hadolint `# linter for Dockerfiles` \
	dive `# useful tool to inspect docker images` \
	ncdu `# ncurses du (find big files/dirs fast)` \
    kubectx `# kubectx and kubens, simplify k8s access` \
    k9s `# simplify k8s access even more` \
    ripgrep `# nvim: required by telescope live_grep` \
    fd `# nvim: required by telescope find_files` \
    node `# nvim: required by Mason for basedpyright/jsonls/yamlls LSP servers` \
    tree-sitter-cli `# nvim: required by nvim-treesitter (main branch) to build parsers` \
    coreutils `# nvim: provides timeout, used during plugin presync`
brew install --cask \
    font-jetbrains-mono-nerd-font `# nvim: full Nerd Font glyph range for nvim-web-devicons; MesloLGS NF (p10k font) only covers p10k glyphs and relies on macOS font fallback for the rest`

# Pyenv
echo "Checking for pyenv..."
if ! command -v pyenv > /dev/null ; then
    echo "Looks like pyenv is not installed, proceeding with install through brew."
    brew install pyenv pyenv-virtualenv
else
    echo "pyenv seems to be installed"
fi

PYTHON_CONFIGURE_OPTS="--enable-framework" pyenv install -s "${PY3_VERSION}"
pyenv global "${PY3_VERSION}"
pip install --upgrade pip
pip install --upgrade pipx


# Zsh
echo -e "\nChecking for oh my zsh..."

if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    echo "Could not find oh-my-zsh dir. Installing..."
    export CHSH=no  # chsh is no longer needed since MacOS Catalina
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
if command -v timeout > /dev/null; then
    timeout 120 nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
else
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
fi

# Enable repeating keys (disable the popup to select diacritics etc):
defaults write -g ApplePressAndHoldEnabled -bool false

# Speed up key repeat and shorten the initial delay before repeat starts:
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

# Rectangle: deploy custom window-snapping shortcuts (tuned for Kinesis Advantage 2 layout).
# Quit first (Rectangle rewrites its prefs on exit), wipe the domain so ONLY these
# shortcuts are bound (no stock defaults linger), write our set, then relaunch.
echo -e "\nConfiguring Rectangle shortcuts..."
osascript -e 'quit app "Rectangle"' 2>/dev/null || true
defaults delete com.knollsoft.Rectangle 2>/dev/null || true

defaults write com.knollsoft.Rectangle leftHalf        '{ keyCode = 123; modifierFlags = 1310720; }'
defaults write com.knollsoft.Rectangle rightHalf       '{ keyCode = 124; modifierFlags = 1310720; }'
defaults write com.knollsoft.Rectangle topHalf         '{ keyCode = 126; modifierFlags = 1572864; }'
defaults write com.knollsoft.Rectangle bottomHalf      '{ keyCode = 125; modifierFlags = 1572864; }'
defaults write com.knollsoft.Rectangle topLeft         '{ keyCode = 18;  modifierFlags = 1310720; }'
defaults write com.knollsoft.Rectangle topRight        '{ keyCode = 19;  modifierFlags = 1310720; }'
defaults write com.knollsoft.Rectangle bottomLeft      '{ keyCode = 20;  modifierFlags = 1310720; }'
defaults write com.knollsoft.Rectangle bottomRight     '{ keyCode = 21;  modifierFlags = 1310720; }'
defaults write com.knollsoft.Rectangle maximize        '{ keyCode = 42;  modifierFlags = 1572864; }'
defaults write com.knollsoft.Rectangle nextDisplay     '{ keyCode = 45;  modifierFlags = 1572864; }'
defaults write com.knollsoft.Rectangle previousDisplay '{ keyCode = 35;  modifierFlags = 1572864; }'

# Mark config as established so Rectangle does not re-add its built-in default shortcuts.
defaults write com.knollsoft.Rectangle alternateDefaultShortcuts -int 1
defaults write com.knollsoft.Rectangle subsequentExecutionMode  -int 1

open -a Rectangle

echo -e "\nAll done!"
echo "If this is the first time setting up iTerm2, set the font to 'JetBrainsMono Nerd Font' in iTerm2 → Settings → Profiles → Text → Font."
echo "To remap Caps Lock to Escape: System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys → set Caps Lock key to Escape."
echo -e "You will also have to reboot to enable repeating keys.\n\nRunning zsh now..."

zsh
