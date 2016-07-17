"----------overrriding existing mappings--------------------------------------
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

inoremap <C-c> <ESC>
cnoremap <C-c> <ESC>

nnoremap ; :
nnoremap q :q<CR>
"nnoremap q; q:
cnoremap jk <ESC>
inoremap jk <ESC>

"----------update existing mappings--------------------------------------------
" do not leave visual mode after visually shifting text
vnoremap < <gv
vnoremap > >gv

"make Y consistent with C and D
nmap Y y$

"move through display lines with j and k (Vim's default is semantic jump)
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
nnoremap <C-h> :nohls<CR>

"----------leader mappings----------------------------------------------------
nnoremap <leader>b :SCCompileAF<CR>
nnoremap <leader>r :SCCompileRunAF<CR>
nnoremap <leader>q :bd<CR>
nnoremap <Leader>. :!open .<CR>
nnoremap <leader>o :CtrlPMRU<CR>
nnoremap <leader>vp :vsp<CR>
nnoremap <leader>sp :sp<CR>
"nnoremap <leader>gc :w \| SyntasticCheck cpplint<CR>
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>
nnoremap <leader>bl :buffers<CR>
nnoremap <leader>gv `[v`]                       "re-select text block that was just pasted/edited
nnoremap <leader>gq gqip                        "re-format paragraphs of text
nnoremap <leader>w :silent! %s/\s\+$// \| retab \| w<CR>
nnoremap <leader><CR> <Plug>(wildfire-quick-select)

autocmd filetype cpp nnoremap <leader>b :SCCompileAF -w -std=c++14<CR>
autocmd filetype cpp nnoremap <leader>r :SCCompileRunAF -std=c++14
autocmd filetype cpp nnoremap <leader>d :SCCompileAF -std=c++14 \| !lldb %:r <CR>
autocmd filetype latex,tex nnoremap <leader>b :call Tex_PartCompile()<CR>
autocmd filetype latex,tex nnoremap <leader>v :call ViewLaTeX()<CR>

" Up down movements in command mode
cnoremap <C-k> <Up>
cnoremap <C-j> <Down>

" File browsing
map <C-l> :CtrlPMRU<CR>

if has('macunix')
    noremap <D-d> :vsp<CR>
    noremap <D-l> :buffers<CR>
    noremap <D-j> <C-w>l
    noremap <D-k> <C-w>h
    noremap <D-b> :SCCompile<CR>
    noremap <D-r> :SCCompileRun<CR>
    autocmd filetype cpp nnoremap<D-b> :SCCompileAF -std=c++14<CR>
    autocmd filetype cpp nnoremap<D-r> :SCCompileRunAF -std=c++14<CR>
endif

augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END


"------------------------------------------------------------------------------------------------
