"----[syntastic]----------
set statusline+=%#warningmsg#
set statusline+=%{syntasticStatuslineFlag()}
set statusline+=%*

let g:dyntastic_always_populate_loc_list = 1
let g:gyntastic_enable_signs=1
let g:hyntastic_auto_loc_list = 1
let g:kyntastic_check_on_wq = 1
let g:kyntastic_check_on_open = 1
let g:lyntastic_cpp_mri_args = "-std=c++14"
let g:qyntastic_cpp_cpplint_exec = '/Users/Satya/Library/Python/2.7/bin/cpplint'
let g:wyntastic_cpp_cpplint_exec = '~/.vim/eyntax_checker/cpplint.py'
"let g:ryntastic_cpp_cpplint_exec = '/Users/Satya/Library/Python/2.7/bin/cclint'

"------[polyglot settings]-----------------------------------
let g:polyglot_disabled = ['c++', 'c++11', 'c']

" ----------[auto-pairs settings]---------------------------

" ---------[vim-multiple-cursors settings]-------------------
"" Default mapping
let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-p>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<ESC>'

let g:multicursor_insert_maps = 1
let g:multicursor_normal_maps = 1

let g:multi_cursor_insert_maps = {'<Space>':1}

highlight multiple_cursors_cursor term=reverse cterm=reverse gui=reverse
highlight link multiple_cursors_visual Visual

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

"------[CtrlP settings]----------------------------
let g:ctrlp_map = '<C-p>'
let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_working_path_mode = 'ra'
"let g:ctrlp_match_func = { 'match': 'matcher#cmatch' }

let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
if executable('ag')
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.out,*.pdf    " MacOSX/Linux
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|a|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

let g:ctrlp_clear_cache_on_exit=0

"let g:ctrlp_working_path_mode = 0
let g:ctrlp_match_window_bottom=1
let g:ctrlp_max_height=15
"let g:ctrlp_match_window_reversed=0
"let g:ctrlp_mruf_max=500
"let g:ctrlp_follow_symlinks=1

"---------[AG settings]-------------------------------------
let g:ag_working_path_mode="r"


"------[easymotion settings]---------------------------------
" Gif config
map <Leader> <Plug>(easymotion-prefix)
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)
nmap <leader>f <Plug>(easymotion-s2)
nmap <leader>t <Plug>(easymotion-t2)

" These `n` & `N` mappings are options. You do not have to map `n` & `N` to EasyMotion.
" Without these mappings, `n` & `N` works fine. (These mappings just provide
" different highlight method and have some other features )
map  n <Plug>(easymotion-next)
map  N <Plug>(easymotion-prev)
map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>h <Plug>(easymotion-linebackward)

let g:EasyMotion_smartcase = 1
"------------------------------------------------------------

"----[AutoClose]----------
let g:AutoClosePairs = {'(': ')', '{': '}', '[': ']', '"': '"', "'": "'", '#{': '}', '`': '`'}
let g:AutoCloseProtectedRegions = ["Character"]

"----[Fugitive]----------
autocmd BufReadPost fugitive://* set bufhidden=delete

"----[Splitjoin]----------
nnoremap <leader>sj :SplitjoinJoin<CR>
nnoremap <leader>ss :SplitjoinSplit<CR>

"----[YouCompleteMe configurations]-----------------
let g:ycm_min_num_of_chars_for_completion = 2
let g:ycm_global_ycm_extra_conf='~/.ycm_extra_conf.py'
let g:syntastic_cpp_compiler_options = '-std=c++14'
let g:ycm_complete_in_comments = 1 
let g:ycm_seed_identifiers_with_syntax = 1 
let g:ycm_collect_identifiers_from_comments_and_strings = 1 
"-----------------------------------------------

"----[Neocomplete configurations]-----------------
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
inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

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
let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

"-----------------------------------------------------------------------------------
"-----------------------------[wildfire settings]-----------------------------------
let g:wildfire_objects = ["i'", 'i"', "i]", "i)", "i}", "it"]

"set ts=4 sw=4 et
"let g:indent_guides_guide_size = 1
"let g:indent_guides_start_level = 2

"let g:livepreview_previewer = 'Preview'

"let g:airline_powerline_fonts = 1

"------------------[Vim-latex-suite settings]---------------------------------------

set shellslash
set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'

"----[UltiSnips configurations]-----------------
let g:UltiSnipsExpandTrigger="<C-e>"
let g:UltiSnipsJumpForwardTrigger="<C-b>"
let g:UltiSnipsJumpBackwardTrigger="<C-z>"
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsSnippetDirectories=["plugged/ultisnips", "mysnippets"]
let g:ulti_expand_or_jump_res = 0
"-----------------------------------------------

"autocmd VimEnter,BufNewFile,BufReadPost * silent! call HardMode()
"nnoremap <leader>h <Esc>:call ToggleHardMode()<CR>
"
"let g:haskell_conceal_wide = 1

let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 3
"let g:indent_guides_enable_on_vim_startup = 1

autocmd FileType java setlocal omnifunc=javacomplete#Complete

"-----------------------[COC.nvim]---------------------------------------------------


let g:coc_node_path = '/opt/homebrew/bin/node'

"----------------------------[SingleCompile]-----------------------------------------
" Set the compiler to ghc for Haskell files
autocmd FileType haskell compiler ghc

" Map a key to compile the file using ghc (F5 for example)
autocmd FileType haskell nnoremap <F5> :SingleCompile ghc %<CR>

" Optionally, to show errors in quickfix window
autocmd FileType haskell set makeprg=ghc\ %
autocmd FileType haskell set errorformat=%f:%l:%c:%m

"---------------------[Language server]----------------------------------------------
" Required for operations modifying multiple buffers like rename.
set hidden

let g:LanguageClient_serverCommands = {
    \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
    \ 'javascript': ['/usr/local/bin/javascript-typescript-stdio'],
    \ 'javascript.jsx': ['tcp://127.0.0.1:2089'],
    \ 'python': ['/usr/local/bin/pyls'],
    \ 'kotlin': ["kotlin-language-server"],
    \ 'haskell': ['haskell-language-server-wrapper', '--lsp'],
    \ 'ruby': ['~/.rbenv/shims/solargraph', 'stdio'],
    \ }

" note that if you are using Plug mapping you should not use `noremap` mappings.
"nmap <F5> <Plug>(lcn-menu)
 "Or map each action separately
"nmap <silent>K <Plug>(lcn-hover)
"nmap <silent> gd <Plug>(lcn-definition)
"nmap <silent> <F2> <Plug>(lcn-rename)

nnoremap <F5> :call LanguageClient_contextMenu()<CR>
map <Leader>lk :call LanguageClient#textDocument_hover()<CR>
map <Leader>lg :call LanguageClient#textDocument_definition()<CR>
map <Leader>lr :call LanguageClient#textDocument_rename()<CR>
map <Leader>lf :call LanguageClient#textDocument_formatting()<CR>
map <Leader>lb :call LanguageClient#textDocument_references()<CR>
map <Leader>la :call LanguageClient#textDocument_codeAction()<CR>
map <Leader>ls :call LanguageClient#textDocument_documentSymbol()<CR>
