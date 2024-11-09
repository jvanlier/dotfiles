let g:ycm_server_python_interpreter = 'python3'
syntax on

set encoding=utf-8
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'easymotion/vim-easymotion'
Plugin 'vim-scripts/indentpython.vim'
" Check Python syntax on each save:
Plugin 'vim-syntastic/syntastic'
" PEP-8 checking; press F7 to run it:
Plugin 'nvie/vim-flake8'
" Nice color scheme:
Plugin 'jnurmine/Zenburn'
" Super searching with CTRL-P:
Plugin 'kien/ctrlp.vim'
" Bottom bar:
Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
"Plugin 'hashrocket/vim-macdown'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

"Easy motion from <Leader><Leader> to just <Leader>, which is \ by default.
map <Leader> <Plug>(easymotion-prefix)

" https://realpython.com/vim-and-python-a-match-made-in-heaven/

"split navigations using control key:
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Proper PEP-8 identation but with 100 chars:
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=100 |
    \ set colorcolumn=100 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix |

au BufNewFile,BufRead *.md
    \ set linebreak

au BufNewFile,BufRead *.tex
    \ set linebreak

au BufNewFile,BufRead *.html
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set expandtab |
    \ set autoindent |

au BufNewFile,BufRead Dockerfile
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set expandtab |
    \ set autoindent |

" Flag unneccesary whitespace:
let python_highlight_all=1

" YCM shortcut: goto declaration quickly with backslash-g
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>

" silent prefix to supress error on first startup:
silent! colorscheme zenburn

set nu
set ruler

let &t_SI.="\e[6 q"
let &t_SR.="\e[4 q"
let &t_EI.="\e[1 q"

" By default vim doesn't show the status line if there's only one buffer.
" Override this:
set laststatus=2

" Make backspace on mac work like most other programs:
set backspace=2
