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
    map <leader>e <C-e>
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
    let g:syntastic_cpp_compiler_options = '-std=c++14'
    let g:ycm_complete_in_comments = 1 
    let g:ycm_seed_identifiers_with_syntax = 1 
    let g:ycm_collect_identifiers_from_comments_and_strings = 1 
"-----------------------------------------------

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
    
    nnoremap <leader>o <C-p>
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

"------[easymotion settings]---------------------------------
    "map <Leader> <Plug>(easymotion-prefix)
    " Gif config
    map  <leader>/ <Plug>(easymotion-sn)
    omap <leader>/ <Plug>(easymotion-tn)

    " These `n` & `N` mappings are options. You do not have to map `n` & `N` to EasyMotion.
    " Without these mappings, `n` & `N` works fine. (These mappings just provide
    " different highlight method and have some other features )
    "map  n <Plug>(easymotion-next)
    "map  N <Plug>(easymotion-prev)
    let g:EasyMotion_smartcase = 1
"------------------------------------------------------------
