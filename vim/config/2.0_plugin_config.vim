" ---------[vim-multiple-cursors settings]-------------------
let g:multi_cursor_quit_key='<C-c>'
let g:multi_cursor_quit_key='<Esc>'
let g:multi_cursor_start_key='g<C-n>'
let g:multi_cursor_start_word_key='<C-n>'

let g:multicursor_insert_maps = 1
let g:multicursor_normal_maps = 1

"let g:multi_cursor_insert_maps = {'<Space>':1}

"let g:multi_cursor_normal_maps = {'i':1}

"let g:multi_cursor_exit_from_visual_mode = 0


highlight multiple_cursors_cursor term=reverse cterm=reverse gui=reverse
highlight link multiple_cursors_visual Visual

"" Called once right before you start selecting multiple cursors
"function! Multiple_cursors_before()
  "if exists(':NeoCompleteLock')==2
    "exe 'NeoCompleteLock'
  "endif
"endfunction

"" Called once only when the multiple selection is canceled (default <Esc>)
"function! Multiple_cursors_after()
  "if exists(':NeoCompleteUnlock')==2
    "exe 'NeoCompleteUnlock'
  "endif
"endfunction


"------[easymotion settings]---------------------------------
" Gif config
nmap f <Plug>(easymotion-sn)

map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>h <Plug>(easymotion-linebackward)

let g:EasyMotion_smartcase = 1

"map <Leader><Leader> <Plug>(easymotion-prefix)
"map  / <Plug>(easymotion-sn)
"nmap <leader>f <Plug>(easymotion-s2)
"nmap <leader>t <Plug>(easymotion-t2)
"omap / <Plug>(easymotion-tn)

" These `n` & `N` mappings are options. You do not have to map `n` & `N` to EasyMotion.
" Without these mappings, `n` & `N` works fine. (These mappings just provide
" different highlight method and have some other features )
"map  n <Plug>(easymotion-next)
"map  N <Plug>(easymotion-prev)



"---------[NERD Commenter]----------------------------------------
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Set a language to use its alternate delimiters by default
" let g:NERDAltDelims_java = 1

" Add your own custom formats or override the defaults
" let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

" Allow commenting and inverting empty lines (useful when commenting a region)
" let g:NERDCommentEmptyLines = 1

"------[CtrlP settings]----------------------------
let g:ctrlp_map = '<C-l>'
let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_match_func = { 'match': 'matcher#cmatch' }

let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
let g:ctrlp_clear_cache_on_exit=0
let g:ctrlp_match_window_bottom=1
let g:ctrlp_mruf_default_order=1
let g:ctrlp_max_height=15
let g:ctrlp_by_filename = 1
" let g:ctrlp_user_command = 'find %s -type f'

"let g:ctrlp_working_path_mode = 0
"let g:ctrlp_match_window_reversed=0
let g:ctrlp_follow_symlinks=1
let g:ctrlp_show_hidden = 1
let g:ctrlp_mruf_max=500

if exists("g:ctrl_user_command")
  unlet g:ctrlp_user_command
endif

set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.out,*.pdf    " MacOSX/Linux
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|a|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

if executable('ag') " The Silver Searcher
  set grepprg=ag\ --nogroup\ --nocolor
  " let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  let g:ctrlp_user_command = 'ag %s -l --nocolor --nogroup --hidden
      \ --ignore .git
      \ --ignore .svn
      \ --ignore .hg
      \ --ignore .DS_Store
      \ --ignore "**/*.pyc"
      \ -g ""'
endif

" ----------[auto-pairs settings]---------------------------


"------[polyglot settings]-----------------------------------
let g:polyglot_disabled = ['c++', 'c++11', 'c']

"-----------------------[syntastic]-----------------------------------------
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

"---------[AG settings]-------------------------------------
let g:ag_working_path_mode="r"


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
" inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
" function! s:my_cr_function()
"     return (pumvisible() ? "\<C-e>" : "" ) . "\<CR>"
"     " For no inserting <CR> key.
"     "return pumvisible() ? "\<C-y>" : "\<CR>"
" endfunction
" return (pumvisible() ? "\<C-y>" : "" ) . "\<C-e>" . "\<CR>"
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" Close popup by <Space>.
inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

" AutoComplPop like behavior.
" let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended).
" set completeopt+=longest
" let g:neocomplete#enable_auto_select = 1
" let g:neocomplete#disable_auto_complete = 1
" inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

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

"-----------------------------------------------------------------------------

"------[wildfire settings]-----------------------------------
let g:wildfire_objects = ["i'", 'i"', "i]", "i)", "i}", "it"]

"set ts=4 sw=4 et
"let g:indent_guides_guide_size = 1
"let g:indent_guides_start_level = 2

"let g:livepreview_previewer = 'Preview'

"let g:airline_powerline_fonts = 1

"------------------[Vim-latex-suite settings]----------------------------------
set shellslash
set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'

"----[UltiSnips configurations]-----------------
" let g:UltiSnipsExpandTrigger="<C-e>"
" let g:UltiSnipsJumpForwardTrigger="<C-b>"
" let g:UltiSnipsJumpBackwardTrigger="<C-z>"
" let g:UltiSnipsEditSplit="vertical"
" let g:UltiSnipsSnippetDirectories=["plugged/ultisnips", "mysnippets"]
" let g:ulti_expand_or_jump_res = 0

"----------------NERD Tree-----------------------------------------------------
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif



"-------------------------------------------------------------------------------
"autocmd VimEnter,BufNewFile,BufReadPost * silent! call HardMode()
"nnoremap <leader>h <Esc>:call ToggleHardMode()<CR>
"
"let g:haskell_conceal_wide = 1

let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 3
"let g:indent_guides_enable_on_vim_startup = 1

"autocmd FileType java setlocal omnifunc=javacomplete#Complete

"----------------Neo Snippets ------------------------------------------------
" Plugin key-mappings.
imap <C-e>     <Plug>(neosnippet_expand_or_jump)
" inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
" function! s:my_cr_function()
"     return (pumvisible() ? "\<Plug>(neosnippet_expand_or_jump)" : "" ) . "\<CR>"
"     " For no inserting <CR> key.
"     "return pumvisible() ? "\<C-y>" : "\<CR>"
" endfunction
smap <C-e>     <Plug>(neosnippet_expand_or_jump)
xmap <C-e>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
imap <expr><TAB>
\ pumvisible() ? "\<C-n>" :
\ neosnippet#expandable_or_jumpable() ?
\    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif
" Enable snipMate compatibility feature.
let g:neosnippet#enable_snipmate_compatibility = 1

" Tell Neosnippet about the other snippets
" let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'
let g:neosnippet#snippets_directory='~/.vim/mysnippets'
