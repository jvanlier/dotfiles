# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Disable auto-setting terminal title:
DISABLE_AUTO_TITLE="true"

# Display red dots whilst waiting for completion:
COMPLETION_WAITING_DOTS="true"

plugins=(
  git
  zsh-autosuggestions
  vi-mode
)

source $ZSH/oh-my-zsh.sh

# User configuration
#
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
alias icloud="${HOME}/Library/Mobile\ Documents/com~apple~CloudDocs"
alias up="cd .."
alias cd..="cd .."

# For vi-mode, switch to block in command mode. And vertical bar for insert 
# mode. Sources: 
# https://emily.st/2013/05/03/zsh-vi-cursor/
# https://github.com/neovim/neovim/issues/2583
function zle-keymap-select zle-line-init
{
    # change cursor shape in iTerm2
    case $KEYMAP in
        vicmd)       echo -ne '\e[1 q';; # block cursor
        viins|main)  echo -ne '\e[6 q';; # line cursor
    esac

    zle reset-prompt
    zle -R
}

function zle-line-finish
{
    echo -ne '\e[1 q';  # block cursor
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

# Locale (was needed on MacOS at one point, doesn't seem to hurt elsewhere):
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Needed to support zenburn vim theme on Linux:
export TERM='xterm-256color'

# Pyenv:
export PYENV_ROOT="${HOME}/.pyenv"
export PATH="$PYENV_ROOT/bin:${PATH}"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

# Poetry:
export PATH="$HOME/.poetry/bin:$PATH"
alias pr="poetry run"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

