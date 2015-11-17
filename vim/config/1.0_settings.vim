" ---------------------- Basic configuration settings ------------------------
set autoindent              " Maintain indent levels automatically.
set autochdir               " Automatically change current directory to
                            " current open file's directory.
set antialias               " set antialising on
set backspace=2             " Allow backspacing in basically every possible
                            " situation (the way I like it).
set clipboard=unnamed
set colorcolumn=85
"highlight the current line
set cursorline
"highlight current column
"set cursorcolumn
set display=lastline        "display as much of lastline as possible instead of a lot of @
set foldcolumn=3            " Show a 4-column gutter to the left for
                            " folding characters.
set foldmethod=marker       " Fold on markers; {{{ and }}} by default.
set formatoptions=tqnw      " Auto-wrap by tw, allow 'gq', recognize lists,
                            " and trailing whitespace continues a paragraph.
"set formatoptions=qrn1
set fileformats=unix,dos    " Create UNIX format files by default, but
                            " autodetect dos files.
set guioptions=aivce        " control guioptions
set gdefault                "assume 'g' flag for :substitute
set hidden                  " Don't unload buffers that are abandoned; hide
                            " them.
set hlsearch                " highlight search results
set incsearch               " Search incrementally (while typing).
set ignorecase smartcase    " Case insensitive search unless caps are used
                            " in search term.
"Highlight tabs and trailing whitespaces.  Additionally, display a '·' for
"each trailing whitespace.
"
" Highlighting behavior is color scheme dependent. Solarized highlights tabs
" and trailing whitespaces using hl-CursorLine highlight group which makes
" them stand out, and at the same time are not very 'loud'.
set listchars=tab:\ \ ,trail:·

"display non-printable characters as configured in 'listchars' option
set list
set linespace=1             " set linespace
set laststatus=2            " Always show the status line.
set linebreak               " Wrap text while typing (this is a soft wrap
                            " without textwidth set).
set lazyredraw              "do not update the display when running macros
set mouse=a                 " Allow use of the mouse in all situations.
set modeline                " Always read modeline stuff from the bottom of
                            " files.
set modelines=1             " Read the modeline only from the last line.
set number                  " show line numbers
set shortmess=at
set shortmess+=I
"show current mode down the bottom
set showmode
"show matching brackets.
set showmatch
set showcmd                 " Show commands as I am typing them.
set shiftwidth=4            " That means I like to indent by that amount as
                            " well.
set scrolloff=5             " Don't let the cursor get fewer than 5 lines
                            " away from the edge whenever possible.
set tags=./tags;/           " Search for a file called tags. If it is not
                            " found in the current directory, continue up one
                            " directory at a time until we reach /.
set textwidth=80             " By default, don't wrap at any specific
                            " column.
set ts=4                    " The best tab stop is 4.
set wrap                    " break lines longer than screen width
set whichwrap=h,l,~,[,]     " These keys will move the cursor over line
                            " boundaries ('wrap').
set wildmenu                " Tab completion for files with horizontal list
                            " of choices.
set winminheight=0          " Allow window split borders to touch.

" Save only the given options when using 'mksession'.
set sessionoptions=blank,buffers,curdir,folds,help,tabpages,unix

" If there is support for the unnamed plus register (default X11 clipboard), use
" it as the default yank, delete, change, and put operations.

" Set my colorscheme.
if !has("gui_running")
    let g:solarized_termcolors=256
    let &t_Co=256
endif
colorscheme solarized

let mapleader="\<Space>"           " Use space instead of backslash as my map
                            " leader.
if has('unnamedplus')
    set clipboard=unnamedplus
endif

" Don't create backup files when editing in these locations.
set backupskip=/tmp/*,/private/tmp/*

" Display unprintable characters in a particular way.
" Leave *list* turned off by default, though.
set nolist listchars=tab:›\ ,trail:-,extends:>,precedes:<,eol:¬

" Allow the html syntax file to recognize improper comments.
" Because I use them. Improperly.
let g:html_wrong_comments = 1

" A couple of environment variables for the spelling stuff.
let IspellLang = 'english'

" ------------------------- Version-specific options -------------------------
if v:version > 702
    set undofile
    set undolevels=1000
    set undoreload=10000
    au BufWritePre /tmp/* setlocal noundofile
    au BufWritePre /private/tmp/* setlocal noundofile
endif

"if v:version >= 704
     "With Vim 7.4, relativenumber is definitely the way to go.
    "set relativenumber
"endif
cd ~/Documents/programming
