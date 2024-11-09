dotfiles
========

My dotfiles for a nice and consistent terminal and vim experience on MacOS and Linux.

## Usage

On mac:

```sh
./bootstrap-mac.sh
```

On Debian or Ubuntu:

```sh
./bootstrap-ubuntu.sh
```


## Known issues

- Debian 12 has vim 9.0, whereas 9.1 is needed for YouCompleteMe.
  This is not fatal: the script continues, but you won't get completion in vim.
- Resize bug in iTerm 2 with powerline10k: while resizing with the mouse, the prompt gets redrawn multiple times.
  There's a [mitigation](https://github.com/romkatv/powerlevel10k#horrific-mess-when-resizing-terminal-window) that involves disabling all right hand side elements.
  Better mitigation: just do not use mouse resize.
  Use Rectangle on Mac.
