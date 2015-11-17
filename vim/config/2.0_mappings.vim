"----------overrriding existing mappings--------------------------------------
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

nnoremap ; :
nnoremap q; q:
cnoremap jk <ESC>
"vnoremap jk <ESC>
inoremap jk <ESC>

"----------update existing mappings--------------------------------------------
" do not leave visual mode after visually shifting text
vnoremap < <gv
vnoremap > >gv

"make Y consistent with C and D
nmap Y y$

"re-select text block that was just pasted/edited
nnoremap <leader>gv `[v`]

"re-format paragraphs of text
nnoremap <leader>gq gqip

"move through display lines with j and k (Vim's default is semantic jump)
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
"----------leader mappings----------------------------------------------------
nnoremap <leader>q :bd<CR>
nnoremap <leader>p :VimFilerExplorer<CR>

"move through tabs
nnoremap <C-t>     :tabnew<CR>
nnoremap <C-Tab>   :tabnext<CR>
nnoremap <C-S-Tab> :tabprev<CR>

" Up down movements in command mode
cnoremap <C-j> <Up>
cnoremap <C-k> <Down>

if has('macunix')
    map <D-d> :vsp<CR>
    map <D-S-d> :sp<CR>
    map <D-l> :buffers<CR>
    nnoremap<D-j> <C-w>l
    nnoremap<D-k> <C-w>h
    autocmd filetype cpp nnoremap<D-b> :silent Shell clang++ -std=c++14 % -o %:r.out<CR>
    nnoremap<D-b> :SCCompileAF
    "autocmd filetype cpp nnoremap<D-r> ! clang++ -std=c++14 % -o %:r && ./%:r<CR>
    "autocmd filetype cpp nnoremap<D-r> :SCCompileRunAF -std=c++14<CR>
endif
"nnoremap<leader>b :SCCompileAF

"autocmd filetype cpp nnoremap<leader>b :silent Shell clang++ -std=c++14 % -o %:r<CR>
"autocmd filetype cpp :UltiSnipsAddFiletypes cpp

"autocmd filetype cpp nnoremap<leader>r :SCCompileRunAF -std=c++14<CR>

augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END


"just scroll
"map <Down> 2<C-e>
"map <Up> 2<C-y>

"nnoremap <leader>o :<C-u>Unite -buffer-name=files buffer neomru/file file_rec/async<CR>
"nnoremap <leader>y :<C-u>Unite history/yank<CR>
"nnoremap <leader>f :<C-u>Unite outline<CR>
"nnoremap <leader>s :<C-u>Unite session<CR>
"nnoremap <leader>c :<C-u>Unite -horizontal -direction=botright -buffer-name=unite_commands command mapping<CR>
"doesn't seem to work
"nnoremap <leader>t :<C-u>Unite tag<CR>
"nnoremap <leader>y :<C-u>Unite history/yank<CR>

"use <C-l> to clear the highlight of search hits
nnoremap <C-l> :nohls<CR>
"inoremap <C-l> <C-O>:nohls<CR>

"------------------------------------------------------------------------------------------------
