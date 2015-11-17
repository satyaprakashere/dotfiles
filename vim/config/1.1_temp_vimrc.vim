"setup filer
let g:vimfiler_as_default_explorer=1

"----[Display]----------

"alter the look and feel of the drop-down menu
:highlight Pmenu ctermbg=238 gui=bold



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


"----[Editing]----------

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

map <ScrollWheelUp> <nop>
map <ScrollWheelDown> <nop>
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
