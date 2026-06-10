-- Non-plugin keymaps. Plugin keymaps live in each plugin spec's keys = {} table.

local map = vim.keymap.set

-- Window navigation (ported from .vimrc C-jkhl split navigation).
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Clear search highlight.
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
