"----------overrriding existing mappings--------------------------------------
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

"move through display lines with j and k (Vim's default is semantic jump)
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

nnoremap q :q<CR>

"do not leave visual mode after visually shifting text
vnoremap < <gv
vnoremap > >gv

"make Y consistent with C and D
nmap Y y$

"----------------------Command Mode Mappings----------------------------------
"Up down movements in command mode
cnoremap jk <ESC>
cnoremap <C-k> <Up>
cnoremap <C-j> <Down>
"cnoremap <C-c> <ESC>           "Not working

"----------------------Insert Mode Mappings-----------------------------------
inoremap jk <ESC>
inoremap <C-c> <ESC>

"----------------------Normal Mode Mappings-----------------------------------
nnoremap ; :
nnoremap <C-h> :nohls<CR>
nnoremap <C-x> :
"nnoremap cm gc

"-----------------------Meta Key Mappings------------------------------------
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-h> <C-w>h
nnoremap <M-l> <C-w>l
nnoremap <M-d> :vsp<CR>
nnoremap <M-j> <C-w>l
nnoremap <M-k> <C-w>h
"nnoremap <silent> <Esc> :nohlsearch<Bar>:echo<CR>


"----------leader mappings----------------------------------------------------
nnoremap <leader>r :SCCompileRun<CR>
nnoremap <Leader>. :!open .<CR>
nnoremap <leader>o :CtrlPMixed<CR>
nnoremap <leader>h :sp<CR>
nnoremap <leader>v :vsp<CR>
nnoremap <leader><CR> <Plug>(wildfire-quick-select)

"nnoremap <leader>b :SCCompile<CR>
"nnoremap <leader>q :bd<CR>
"nnoremap <leader>vp :vsp<CR>
"nnoremap <leader>sp :sp<CR>
"nnoremap <leader>gc :w \| SyntasticCheck cpplint<CR>
"nnoremap <leader>bn :bn<CR>
"nnoremap <leader>bp :bp<CR>
"nnoremap <leader>bl :buffers<CR>
"nnoremap <leader>gv `[v`]                       "re-select text block that was just pasted/edited "nnoremap <leader>gq gqip                        "re-format paragraphs of text "nnoremap <leader>wt :silent! %s/\s\+$// \| retab <CR> "nnoremap <leader>s :w<CR>

"autocmd filetype cpp nnoremap <leader>b :SCCompileAF -w -std=c++14<CR>
"autocmd filetype cpp nnoremap <leader>r :SCCompileRunAF -std=c++14
"autocmd filetype cpp nnoremap <leader>d :SCCompileAF -std=c++14 \| !lldb %:r <CR>

"autocmd filetype idris nnoremap <leader>b :!idris % -o %:r<CR>
"autocmd filetype idris nnoremap <leader>r :!./%:r<CR>

"autocmd filetype haskell nnoremap <leader>b :!ghc -o $:r %<CR>
"autocmd filetype haskell nnoremap <leader>r :!runhaskell %<CR>

"autocmd filetype latex,tex nnoremap <leader>b :call Tex_PartCompile()<CR>
"autocmd filetype latex,tex nnoremap <leader>v :call ViewLaTeX()<CR>

"---------------------------------GUI settings-------------------------------------
if has('gui_running')
    "noremap <D-d> :vsp<CR>
    "noremap <D-j> <C-w>l
    "noremap <D-k> <C-w>h
    noremap <D-l> :buffers<CR>
    noremap <D-b> :SCCompile<CR>
    noremap <D-r> :SCCompileRun<CR>

    autocmd filetype cpp nnoremap<D-b> :SCCompileAF -std=c++14<CR>
    autocmd filetype cpp nnoremap<D-r> :SCCompileRunAF -std=c++14<CR>
    " autocmd filetype haskell nnoremap <D-r> :!runhaskell %<CR>
    " autocmd filetype haskell nnoremap <D-b> :!ghc -o $:r %<CR>
endif

"augroup myvimrc
    "au!
    "au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
"augroup END

"------------------------------------------------------------------------------------------------
