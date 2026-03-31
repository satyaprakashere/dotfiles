" ----[ Basic settings ]----------
let mapleader="\<Space>"
set termguicolors

" Appearance
let g:lightline = {'colorscheme': 'catppuccin_mocha'}
colorscheme catppuccin_mocha

" ----[ Editing ]----------
filetype plugin indent on
syntax on
set encoding=utf-8
set autoindent
set backspace=2
set completeopt=menu,menuone,noselect,preview
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set shiftround
set smarttab
set textwidth=100
set formatoptions=qrn12
set modeline
set modelines=1

" Clipboard
if has('macunix')
  set clipboard=unnamed
else
  set clipboard=unnamedplus
endif

set mouse=a

" ----[ Display ]----------
set cursorline
set number
set relativenumber
set colorcolumn=85
set laststatus=2
set shortmess+=I
set showcmd
set showmatch
set scrolloff=5
set display=lastline
set lazyredraw
set wrap
set whichwrap=h,l,~,[,]
set list
set listchars=tab:»\ ,trail:·

" ----[ Buffer & Search ]----------
set hidden
set autochdir
set nobackup
set nowritebackup
set noswapfile
set autoread
set autowriteall
set hlsearch
set incsearch
set ignorecase
set smartcase
set splitright
set splitbelow
set wildmenu
set wildmode=longest:full,full
set wildignore=*.o,*.obj,*~,*.so,*.swp,*.zip,*.out,*.pdf

" Undo persistence
if has('persistent_undo')
    let g:undo_dir = expand('~/.vim/undo')
    if !isdirectory(g:undo_dir)
        call mkdir(g:undo_dir, 'p')
    endif
    let &undodir = g:undo_dir
    set undofile
endif

" Jump to last position when reopening a file
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" ----[ Language Specific ]----------
let g:tex_flavor='latex'
autocmd filetype sh,haskell,python,rekursion setlocal shiftwidth=2 softtabstop=2
autocmd FileType swift setlocal shiftwidth=2 tabstop=2 expandtab

" Path additions
let $PATH .= ':' . expand('~/.ghcup/bin')
let $PATH .= ':' . '/opt/homebrew/bin'

" Goyo enter/leave hooks
autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

function! s:goyo_enter()
    colorscheme pencil
endfunction

function! s:goyo_leave()
    colorscheme catppuccin_mocha
endfunction
