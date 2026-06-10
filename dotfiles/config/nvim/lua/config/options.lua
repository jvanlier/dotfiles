-- General editor options (ported and modernised from the old .vimrc).

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.ruler = true
opt.laststatus = 2          -- always show statusline (old .vimrc set laststatus=2)
opt.termguicolors = true    -- 24-bit colour, needed by modern colorschemes/plugins
opt.signcolumn = "yes"      -- avoid layout shift when diagnostics/git signs appear
opt.updatetime = 250        -- snappier CursorHold (gitsigns, diagnostics)
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.backspace = "indent,eol,start"  -- old .vimrc: set backspace=2
opt.ignorecase = true
opt.smartcase = true
opt.undofile = true         -- persistent undo

-- Cursor shape: block in normal, bar in insert (replaces the old t_SI/t_EI escape sequences).
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- Filetype-specific settings (replaces the au BufNewFile,BufRead blocks in .vimrc).
local ft = vim.api.nvim_create_augroup("UserFiletypeSettings", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = ft,
  pattern = "python",
  callback = function()
    local o = vim.opt_local
    o.tabstop = 4
    o.softtabstop = 4
    o.shiftwidth = 4
    o.textwidth = 120
    o.colorcolumn = "120"
    o.expandtab = true
    o.autoindent = true
    o.fileformat = "unix"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = ft,
  pattern = { "markdown", "tex" },
  callback = function()
    vim.opt_local.linebreak = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = ft,
  pattern = { "html", "dockerfile" },
  callback = function()
    local o = vim.opt_local
    o.tabstop = 4
    o.softtabstop = 4
    o.shiftwidth = 4
    o.expandtab = true
    o.autoindent = true
  end,
})
