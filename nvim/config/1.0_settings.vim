" ---------------------- Basic configuration settings ------------------------
let mapleader="\<Space>"    " Use space instead of backslash as my leader key

"let $NVIM_TUI_ENABLE_CURSOR__SHAPE=1
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set background=light
colorscheme solarized
let g:Guifont="Menlo for Powerline:h12"
let g:python_host_prog = '/usr/local/bin/python'

" ------------------------- [Editing] ----------------------------------------
filetype plugin indent on           " filetype detection on
syntax on                           " switch on syntax highlighting
set encoding=utf-8                  " set file encoding
set autoindent                      " Maintain indent levels automatically.
"set antialias                       " set antialising on
set backspace=2                     " Allow backspacing in basically every possible
                                    " situation (the way I like it).
set complete=.,w,b,u,t,i,d,k,s      "set keyword completion options
set completeopt=menu,longest,preview "set what to show in the popup menu
set expandtab                       " expand tab into spaces
set fileformats=unix,dos            " Create UNIX format files by default, but
                                    " autodetect dos files.
set linebreak                       " Wrap text while typing (this is a soft wrap
                                    " without textwidth set).
set modeline                        " Always read modeline stuff from the bottom of
                                    " files.
set modelines=1                     " Read the modeline only from the last line.
set softtabstop=4
set shiftwidth=4                    " number of spaces to use when (auto)indenting (=, <<, >>)
set shiftround                      "round indent to a multiple of shiftwidth
set smarttab                        "use shiftwidth when inserting <Tab> in front of a line
set textwidth=100                    " By default, don't wrap at any specific
                                    " column.
set tabstop=4                       " The best tab stop is 4.
let IspellLang = 'english'          " A couple of environment variables for the spelling stuff.
set wildmenu                        "enable enhanced command line completion
set wildmode=longest:full,full      "using bash style
set wildignore=*.o,*.obj,*~         "ignoring the following file patterns

" use system clipoard for yank, delete and paste operations
if has('macunix')
  set clipboard=unnamed
else "linux
  set clipboard=unnamedplus
endif

" ---------------------------- [Display] -------------------------------------
set autochdir                       " Automatically change current directory to
                                    " current open file's directory.
set colorcolumn=85                  " highlight column 85
set cursorline                      " highlight current cursor line
set display=lastline                " display as much of lastline as possible instead of a lot of @
set nofoldenable                    " disable folding
set foldcolumn=3                    " Show a 4-column gutter to the left for
                                    " folding characters.
set foldmethod=marker               " Fold on markers; {{{ and }}} by default.
set formatoptions=qrn12             " Auto-wrap by tw, allow 'gq', recognize lists,
                                    " and trailing whitespace continues a paragraph.
set guioptions=aivce                " control guioptions
set list                            " display non-printable characters as configured in 'listchars' option
set linespace=1                     " set linespace
set laststatus=2                    " Always show the status line.
set mouse=a                         " Allow use of the mouse in all situations.
set number                          " show line numbers
set shortmess=at
set shortmess+=I                    " hide Vim welcome screen
set showmode                        " show current mode down the bottom
set showmatch                       " show matching brackets.
"set showcmd                         " Show commands as I am typing them.
set scrolloff=5                     " Don't let the cursor get fewer than 5 lines
set wrap                            " break lines longer than screen width
set whichwrap=h,l,~,[,]             " These keys will move the cursor over line
                                    " boundaries ('wrap').
                                    " away from the edge whenever possible.

"Highlight tabs and trailing whitespaces.Additionally, display a '·' for each trailing whitespace.
set listchars=tab:\ \ ,trail:·
" -----------------------------[Browsing & Buffer management] -------------------------------------

set nobackup                        " don't use a swap or a backup file
set nowritebackup
set noswapfile
set viminfo+=n~/.vim/viminfo        " save viminfo to ~/.vim
set autoread                        " automatically read a file that has been changed externally
set autowriteall                    " save the file when switching buffers or compile
autocmd FocusLost * silent! wa      " automatically save buffers when Vim looses focus
set hidden                          " Don't unload buffers that are abandoned; hide them.
set wildmenu                        " Tab completion for files with horizontal list of choices.
set winminheight=0                  " Allow window split borders to touch.

" Don't create backup files when editing in these locations.
set backupskip=/tmp/*,/private/tmp/*
"jump to the last position when reopening a file
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

"enable undo persistence for all but tmp files
let g:undo_dir = $HOME . "/.vim/undo"
if !isdirectory(g:undo_dir)
    call mkdir(g:undo_dir)
endif
set undofile
let &undodir=g:undo_dir
autocmd BufWritePre /tmp/* setlocal noundofile
autocmd BufWritePre */.git/COMMIT_EDITMSG setlocal noundofile

"---------------------- [Searching and Substitution]--------------------------
set gdefault                " assume 'g' flag for :substitute
set hlsearch                " highlight search results
set incsearch               " Search incrementally (while typing).
set ignorecase smartcase    " Case insensitive search unless caps are used
                            " in search term.
set tags=./tags;/           " Search for a file called tags. If it is not
                            " found in the current directory, continue up one
                            " directory at a time until we reach /.

set splitright              "create a window to the right of the current one on a vertical split
set splitbelow              "create a window below the current one on a horizontal split

"jump to the first open window that contains the specified buffer; this works
"only for quickfix commands, and buffer related split commands
set switchbuf=usetab

" Save only the given options when using 'mksession'.
set sessionoptions=blank,buffers,curdir,folds,help,tabpages,unix


let g:tex_flavor='latex'
" If there is support for the unnamed plus register (default X11 clipboard), use
" it as the default yank, delete, change, and put operations.
if has('unnamedplus')
    set clipboard=unnamedplus
endif

" ------------------------- Version-specific options -------------------------
if v:version > 702
    set undofile
    set undolevels=1000
    set undoreload=10000
    au BufWritePre /tmp/* setlocal noundofile
    au BufWritePre /private/tmp/* setlocal noundofile
endif

if v:version >= 704
     "With Vim 7.4, relativenumber is definitely the way to go.
    set relativenumber
endif
