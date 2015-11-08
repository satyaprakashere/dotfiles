"----[Plugin manager Vundle setup]-----------------
    set nocompatible            "make Vim non compatible with Vim
    filetype off                "required for Vundle

    set rtp+=~/.vim/bundle/Vundle.vim           "set the runtime path to include Vundle and initialize
    call vundle#begin()

    Plugin 'VundleVim/Vundle.vim'               " let Vundle manage Vundle, required

    if has('gui_macvim') || !has('gui_running') " Disabling YCM in VimR (doesn't work due to conflict in python bindings)
        Bundle 'Valloric/YouCompleteMe'
        Bundle 'scrooloose/nerdtree'
    endif
    if has('lua') 
        Bundle 'Shougo/neocomplete.vim'
        Bundle 'SirVer/ultisnips'
    endif
    Bundle 'vim-latex/vim-latex'
    Bundle 'severin-lemaignan/vim-minimap'
    Bundle 'kien/ctrlp.vim'
    Bundle 'tpope/vim-fugitive'
    "Bundle 'bling/vim-airline'
    "Bundle 'wincent/command-t'
    "Bundle 'mileszs/ack.vim'
    "Bundle 'mkarmona/materialbox'
    Bundle 'honza/vim-snippets'
    Bundle 'scrooloose/nerdcommenter'
    Bundle 'terryma/vim-multiple-cursors'
    "Bundle 'sollidsnake/vterm'
    "Bundle 'Raimondi/delimitMate'
    Bundle 'scrooloose/syntastic'
    "Bundle 'xuhdev/SingleCompile'
    Bundle 'jiangmiao/auto-pairs'

    call vundle#end()                           " All of your Plugins must be added before the following line
"--------------------------------------------------

"----[General Settings]----------------------------

"----[Filetype]----------
"switch on filetype identification
"enable builtin plugins for various filetypes
"enable builtin indenting scheme for various filetypes
filetype plugin indent on

"set default file type cpp
"set filetype?
"set filetype=cpp

"switch on syntax highlighting
syntax on

set encoding=utf-8

set number

" Automatically change current directory to current open file's directory.
set autochdir

"color scheme
"let g:solarized_termtrans=1
if !has('gui_running')
    set background=light
    let g:solarized_termcolors=256
endif
colorscheme solarized

"use option (alt) as meta key on Mac
if has('macunix')
  set macmeta
endif

"set cmdheight=2

"use , over \ as leader
"let mapleader = ","

"enable mouse use in all modes
set mouse=a

"recognise mouse for xterm type terminals
set ttymouse=xterm2

"do not display :intro at Vim start
"set shortmess+=I

set shortmess=a

"always display status line
set laststatus=2

"----[Gvim]----------
"set the font
if has('macunix')
  "set guifont=Incosolata-dz:h13
  set guifont=Monaco:h12
else  "linux
  set guifont=Droid\ Sans\ Mono\ 11
endif

"control guioptions
set guioptions=aivce

"set linespace
set linespace=1

"set antialising on
set antialias

"setup filer
let g:vimfiler_as_default_explorer=1

"----[Display]----------
"break lines longer than screen width
set wrap

set textwidth=79

set formatoptions=qrn1

set colorcolumn=85

"break lines at characters in 'breakat'
set linebreak

"set background=light
"colorscheme jellybeans

"do not update the display when running macros
set lazyredraw

"display as much of lastline as possible instead of a lot of @
set display=lastline

"alter the look and feel of the drop-down menu
:highlight Pmenu ctermbg=238 gui=bold


"----[Visual Hints]----------
"Highlight tabs and trailing whitespaces.  Additionally, display a '·' for
"each trailing whitespace.
"
" Highlighting behavior is color scheme dependent. Solarized highlights tabs
" and trailing whitespaces using hl-CursorLine highlight group which makes
" them stand out, and at the same time are not very 'loud'.
set listchars=tab:\ \ ,trail:·

"display non-printable characters as configured in 'listchars' option
set list

"show (partial) command in status line
set showcmd

"show current mode down the bottom
set showmode

"show matching brackets.
set showmatch

"highlight the current line
set cursorline


"highlight current column
"set cursorcolumn


"----[Browsing]----------
"search for tags file in the directory of the current file and upwards
set tags=./tags;

"create a window to the right of the current one on a vertical split
set splitright

"create a window below the current one on a horizontal split
set splitbelow

"jump to the first open window that contains the specified buffer; this works
"only for quickfix commands, and buffer related split commands
set switchbuf=usetab

"keep three lines above and below the cursor all the times
set scrolloff=3

" Unite settings and mappings
let g:unite_enable_start_insert = 1
let g:unite_enable_split_vertically = 1
let g:unite_kind_file_vertical_preview = 1
let g:unite_source_history_yank_enable = 1
"call unite#filters#matcher_default#use(['matcher_fuzzy'])
"call unite#filters#sorter_default#use(['sorter_rank'])
"call unite#custom#source('file_rec/async', 'sorters', 'sorter_rank')


let g:unite_source_history_yank_enable = 1

"----[Searching and Substitution]----------
"do incremental and
set incsearch

"case insensitive search
set ignorecase

"unless query starts with a capital letter
set smartcase

"and highlight the search terms
set hlsearch

"assume 'g' flag for :substitute
set gdefault

"----[Editing]----------
"number of spaces that a <Tab> counts for while editing (<Tab>, <BS>)
set softtabstop=4

"number of spaces that a <Tab> counts for
set tabstop=4

"expand tab into spaces
set expandtab

"number of spaces to use when (auto)indenting (=, <<, >>)
set shiftwidth=4

"round indent to a multiple of shiftwidth
set shiftround

"use shiftwidth when inserting <Tab> in front of a line
set smarttab

"smart autoindenting
set smartindent

" Called once right before you start selecting multiple cursors
function! Multiple_cursors_before()
  if exists(':NeoCompleteLock')==2
    exe 'NeoCompleteLock'
  endif
endfunction

" Called once only when the multiple selection is canceled (default <Esc>)
function! Multiple_cursors_after()
  if exists(':NeoCompleteUnlock')==2
    exe 'NeoCompleteUnlock'
  endif
endfunction

"use system clipoard for yank, delete and paste operations
if has('macunix')
  set clipboard=unnamed
else "linux
  set clipboard=unnamedplus
endif

"toggle paste mode
set pastetoggle=<F10>


"----[Buffer]----------
"don't use a swap or a backup file
set nobackup
set nowritebackup
set noswapfile

"hide a buffer when abnandoned, rather than unloading it
set hidden

"automatically read a file that has been changed externally
set autoread

"save the file when switching buffers or compile
set autowrite

"automatically save buffers when Vim looses focus
autocmd FocusLost * silent! wa

"enable undo persistence for all but tmp files
let g:undo_dir = $HOME . "/.vim/undo"
if !isdirectory(g:undo_dir)
    call mkdir(g:undo_dir)
endif
set undofile
let &undodir=g:undo_dir
autocmd BufWritePre /tmp/* setlocal noundofile
autocmd BufWritePre */.git/COMMIT_EDITMSG setlocal noundofile

"access undo tree
nnoremap <leader>u :GundoToggle<CR>

"set omnicompletion for Ruby, Eruby and Rails
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1

"set keyword completion options
set complete=.,w,b,u,t,i,d,k,s

"set what to show in the popup menu
set completeopt=menu,longest,preview

"enable enhanced command line completion
set wildmenu

"using bash style
set wildmode=longest:full,full

"ignoring the following file patterns
set wildignore=*.o,*.obj,*~


"----[Abbreviations]----------
"expand %% to pwd on the command line
cabbr <expr> %% expand('%:p:h')


"----[Session]----------
"save viminfo to ~/.vim
set viminfo+=n~/.vim/viminfo

let g:unite_source_session_enable_auto_save=1
let g:unite_source_session_options="folds,tabpages,winsize"

"jump to the last position when reopening a file
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif


"----[Syntastic]----------
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=1
let g:syntastic_disabled_filetypes = ['c', 'cpp']

"ignore modern HTML5 weirdness (Angular, Bootstrap, FontAwesome)
let g:syntastic_html_tidy_ignore_errors=[
      \" proprietary attribute \"ng-",
      \"<ng-include> is not recognized",
      \"discarding unexpected <ng-include>",
      \"discarding unexpected </ng-include>",
      \"trimming empty <i>",
      \"trimming empty <span>",
      \"<input> proprietary attribute \"autocomplete\"",
      \"proprietary attribute \"role\"",
      \"proprietary attribute \"am-time-ago\"",
      \"attribute \"tabindex\" has invalid value \"-1\""
      \]


"----[snipmate]----------
let g:snips_author = "Satya Prakash"


"----[AutoClose]----------
let g:AutoClosePairs = {'(': ')', '{': '}', '[': ']', '"': '"', "'": "'", '#{': '}', '`': '`'}
let g:AutoCloseProtectedRegions = ["Character"]


"----[Fugitive]----------
autocmd BufReadPost fugitive://* set bufhidden=delete


"----[Splitjoin]----------
nnoremap <leader>sj :SplitjoinJoin<CR>
nnoremap <leader>ss :SplitjoinSplit<CR>

"----[Vimshell]----------
"nnoremap <leader>r :VimShellInteractive irb
"nnoremap <leader>rs :'<,'>VimShellSendString


"----[UltiSnips configurations]-----------------
    let g:UltiSnipsExpandTrigger="<C-e>"
    "if has('gui_running') && !has('gui_macvim')
        "let g:UltiSnipsExpandTrigger="<tab>"
    "endif
    let g:UltiSnipsJumpForwardTrigger="<C-b>"
    let g:UltiSnipsJumpBackwardTrigger="<C-z>"
    let g:UltiSnipsEditSplit="vertical"
    let g:UltiSnipsSnippetDirectories=["bundle/ultisnips"]
"-----------------------------------------------

"----[YouCompleteMe configurations]-----------------
    let g:ycm_min_num_of_chars_for_completion = 2
    let g:ycm_global_ycm_extra_conf='~/.ycm_extra_conf.py'
    let g:syntastic_cpp_compiler_options = '-std=c++11'
    let g:ycm_complete_in_comments = 1 
    let g:ycm_seed_identifiers_with_syntax = 1 
    let g:ycm_collect_identifiers_from_comments_and_strings = 1 
"-----------------------------------------------

"----[Key mappings]------------------------------------------------------------

    noremap <Up> <NOP>
    noremap <Down> <NOP>
    noremap <Left> <NOP>
    noremap <Right> <NOP>

    let mapleader ="\<Space>"
    nnoremap <F5> :<C-U>make %:r && ./%:r<CR>
    nnoremap ; :
    nnoremap q; q:
    cnoremap jk <ESC>
    vnoremap jk <ESC>
    inoremap jk <ESC>
    nnoremap <leader>p :VimFilerExplorer<CR>

    "move through tabs
    nnoremap <C-t>     :tabnew<CR>
    nnoremap <C-Tab>   :tabnext<CR>
    nnoremap <C-S-Tab> :tabprev<CR>
    cnoremap <C-j> <Up>
    cnoremap <C-k> <Down>

    if has('macunix')
        map <D-d> :vsp<CR>
        "cmap <D-d> <ESC><C-n>
        "map <D-S-d> :sp<Enter>
        map <D-l> :buffers<CR>
        "map <D-f> <C-D-f>
        if has('gui_macvim')
            nnoremap<D-/> <leader>ci
        endif
        nnoremap<D-j> <C-w>l
        nnoremap<D-k> <C-w>h
        nnoremap<D-b> :SCCompileAF
        autocmd filetype cpp nnoremap<D-b> :silent Shell clang++ -std=c++11 % -o %:r<CR>
        "autocmd filetype cpp nnoremap<D-r> ! clang++ -std=c++11 % -o %:r && ./%:r<CR>
        autocmd filetype cpp nnoremap<D-r> :SCCompileRunAF -std=c++11<CR>
    endif
    nnoremap<leader>b :SCCompileAF

    autocmd filetype cpp nnoremap<leader>b :silent Shell clang++ -std=c++11 % -o %:r<CR>
    "autocmd filetype cpp :UltiSnipsAddFiletypes cpp

    autocmd filetype cpp nnoremap<leader>r :SCCompileRunAF -std=c++11<CR>

    augroup myvimrc
        au!
        au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
    augroup END

    "move through display lines with j and k (Vim's default is semantic jump)
    nnoremap j gj
    nnoremap k gk
    nnoremap gj j
    nnoremap gk k

    "just scroll
    map <Down> 2<C-e>
    map <Up> 2<C-y>

    nnoremap <leader>o :<C-u>Unite -buffer-name=files buffer neomru/file file_rec/async<CR>
    nnoremap <leader>y :<C-u>Unite history/yank<CR>
    nnoremap <leader>f :<C-u>Unite outline<CR>
    nnoremap <leader>s :<C-u>Unite session<CR>
    nnoremap <leader>c :<C-u>Unite -horizontal -direction=botright -buffer-name=unite_commands command mapping<CR>
    "doesn't seem to work
    "nnoremap <leader>t :<C-u>Unite tag<CR>
    nnoremap <leader>y :<C-u>Unite history/yank<CR>

    "use <C-l> to clear the highlight of search hits
    nnoremap <C-l> :nohls<CR>
    inoremap <C-l> <C-O>:nohls<CR>

    "make Y consistent with C and D
    nmap Y y$

    "re-select text block that was just pasted/edited
    nnoremap <leader>gv `[v`]

    "re-format paragraphs of text
    nnoremap <leader>gq gqip

    "do not leave visual mode after visually shifting text
    vnoremap < <gv
    vnoremap > >gv

"------------------------------------------------------------------------------------------------

"----[FNeocomplete configurations]-----------------

    "Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
    " Disable AutoComplPop.
    let g:acp_enableAtStartup = 0
    " Use neocomplete.
    let g:neocomplete#enable_at_startup = 1
    " Use smartcase.
    let g:neocomplete#enable_smart_case = 1
    " Set minimum syntax keyword length.
    let g:neocomplete#sources#syntax#min_keyword_length = 3
    let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

    " Define dictionary.
    let g:neocomplete#sources#dictionary#dictionaries = {
        \ 'default' : '',
        \ 'vimshell' : $HOME.'/.vimshell_hist',
        \ 'scheme' : $HOME.'/.gosh_completions'
            \ }

    " Define keyword.
    if !exists('g:neocomplete#keyword_patterns')
        let g:neocomplete#keyword_patterns = {}
    endif
    let g:neocomplete#keyword_patterns['default'] = '\h\w*'

    " Plugin key-mappings.
    inoremap <expr><C-g>     neocomplete#undo_completion()
    inoremap <expr><C-l>     neocomplete#complete_common_string()

    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function()
    return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
    " For no inserting <CR> key.
    "return pumvisible() ? "\<C-y>" : "\<CR>"
    endfunction
    " <TAB>: completion.
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    " Close popup by <Space>.
    "inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

    " AutoComplPop like behavior.
    "let g:neocomplete#enable_auto_select = 1

    " Shell like behavior(not recommended).
    "set completeopt+=longest
    "let g:neocomplete#enable_auto_select = 1
    "let g:neocomplete#disable_auto_complete = 1
    "inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

    " Enable omni completion.
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

    " Enable heavy omni completion.
    if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
    endif
    "let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
    "let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
    "let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

    " For perlomni.vim setting.
    " https://github.com/c9s/perlomni.vim
    let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

"------------------------------------------------------------------------------------------------

"----[Custom Funtions for adding new Functionality]----------------------------------------------

    command! Compile Shell clang++ -std=c++11 % -o %:r
    " Times the number of times a particular command takes to execute the specified
    " number of times (in seconds).
    function! HowLong( command, numberOfTimes )
    " We don't want to be prompted by a message if the command being tried is
    " an echo as that would slow things down while waiting for user input.
    let more = &more
    set nomore
    let startTime = localtime()
    for i in range( a:numberOfTimes )
        execute a:command
    endfor
    let result = localtime() - startTime
    let &more = more
    return result
    endfunction


    " Custom Shell command for executing shell function in a different frame.
    command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)

    function! s:RunShellCommand(cmdline)
    echo a:cmdline
    let expanded_cmdline = a:cmdline
    silent! bw compilation
    "buffer [Scratch]
    "q
    for part in split(a:cmdline, ' ')
        if part[0] =~ '\v[%#<]'
            let expanded_part = fnameescape(expand(part))
            let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
        endif
    endfor
    botright new
    set buflisted
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    resize 10
    "call setline(1, 'You entered:    ' . a:cmdline)
    "call setline(2, 'Expanded Form:  ' .expanded_cmdline)
    file compilation
    let startTime = localtime()
    execute '$read !'. expanded_cmdline
    let result = localtime() - startTime
    echo '[Finished in '.result.'s]'
    "call setline(2,substitute(getline(2),'.','=','g')
    setlocal nomodifiable
    endfunction
"--------------------------------------------------

"------[CtrlP settings]----------------------------

    let g:ctrlp_map = '<c-p>'
    let g:ctrlp_cmd = 'CtrlPMixed'
    let g:ctrlp_working_path_mode = 'ra'
    set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.out    " MacOSX/Linux
    let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
    "let g:ctrlp_custom_ignore = {
                "\ 'dir':  '\v[\/]\.(git|hg|svn)$',
                "\ 'file': '\v\.(exe|so|dll)$',
                "\ 'link': 'some_bad_symbolic_links',
                "\ }
"--------------------------------------------------

"------[Buffer managment plugin]-------------------
    " Enable the list of buffers
    "let g:airline#extensions#tabline#enabled = 1

    " Show just the filename
    "let g:airline#extensions#tabline#fnamemod = ':t'
"---------------------------------------------------

"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
"map <leader>n :NERDTreeToggle<CR>
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
"let g:NERDTreeDirArrows = 1
"let g:NERDTreeDirArrowExpandable = '▸'
"let g:NERDTreeDirArrowCollapsible = '▾'
