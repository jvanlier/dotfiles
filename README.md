dotfiles
========

My dotfiles for a nice and consistent terminal and vim experience on MacOS and Linux.


## Open issues
- Resize bug in iTerm 2 with powerline10k: while resizing with the mouse, the prompt gets redrawn multiple times. There's a [mitigation](https://github.com/romkatv/powerlevel10k#horrific-mess-when-resizing-terminal-window) that involves disabling all right hand side elements. A better solution is to just not mouse resize. Use Rectangle on Mac. `tmux` CTRL-B + arrow resize seems unaffected.
