dotfiles
========

My dotfiles for a nice terminal and vim experience on MacOS and Linux.



## Open issues
- Resize bug: mouse resizing redraws prompt multiple times during resize. There's a [mitigation](https://github.com/romkatv/powerlevel10k#horrific-mess-when-resizing-terminal-window) that involves disabling all right hand side elements. A better solution is to just not mouse resize. Use ShiftIt on Mac. `tmux` CTRL-B + arrow resize seems unaffected. 

## TODO
- finish and test Mac bootstrap script
- create Ubuntu bootstrap script
