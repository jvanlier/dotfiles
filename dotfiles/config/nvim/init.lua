-- Leader must be set before lazy.nvim loads (it reads leader at setup time).
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.lazy_bootstrap")
