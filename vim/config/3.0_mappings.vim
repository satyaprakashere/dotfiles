" ----[ Overriding existing mappings ]----------
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

inoremap <C-c> <ESC>
cnoremap <C-c> <ESC>

nnoremap q :q<CR>
nnoremap ; :
inoremap jk <ESC>
cnoremap jk <ESC>

" ----[ Update existing mappings ]----------
" do not leave visual mode after visually shifting text
vnoremap < <gv
vnoremap > >gv

" make Y consistent with C and D
nnoremap Y y$

" move through display lines with j and k
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

nnoremap <C-h> :nohls<CR>

" Map 'gb' to Go Back in the jump list (Ctrl + O)
nnoremap gb <C-o>

" ----[ Leader mappings ]----------
let mapleader="\<Space>"

" Build and Build/Run (using dotfiles scripts)
nnoremap <leader>b :!bash ~/dotfiles/shell/build-scripts/build.sh %<CR>
nnoremap <leader>r :!bash ~/dotfiles/shell/build-scripts/build_run.sh %<CR>

nnoremap <leader>q :bd<CR>
nnoremap <Leader>. :!open .<CR>
nnoremap <leader>vp :vsp<CR>
nnoremap <leader>sp :sp<CR>
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>
nnoremap <leader>bl :buffers<CR>
nnoremap <leader>gv `[v`]                       " re-select text block that was just pasted/edited
nnoremap <leader>gq gqip                        " re-format paragraphs of text
nnoremap <leader>wt :silent! %s/\s\+$// <Bar> retab <CR>
nnoremap <leader>s :w<CR>

" ----[ Plugin Mappings ]----------

" fzf.vim
nnoremap <C-p> :ProjectFiles<CR>
nnoremap <leader>o :ProjectFiles<CR>
nnoremap <leader>ff :ProjectFiles<CR>
nnoremap <leader>fr :History<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>ft :Tags<CR>

" NERDTree
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>h :NERDTreeToggle<CR>

" coc.nvim
" coc.nvim
" Use tab for trigger completion with characters ahead and navigate
inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#next(1) : CheckBackspace() ? "\<Tab>" : coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Multi-cursor (using wildfire)
nnoremap <leader><CR> <Plug>(wildfire-quick-select)

" Smooth scroll
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>

" Command Mode navigation
cnoremap <C-k> <Up>
cnoremap <C-j> <Down>

" GUI (usually MacVim) specific
if has('macunix')
    noremap <D-d> :vsp<CR>
    noremap <D-l> :buffers<CR>
    noremap <D-j> <C-w>l
    noremap <D-k> <C-w>h
    nnoremap <D-b> :!bash ~/dotfiles/shell/build-scripts/build.sh %<CR>
    nnoremap <D-r> :!bash ~/dotfiles/shell/build-scripts/build_run.sh %<CR>
    nnoremap <D-h> :NERDTreeToggle<CR>
endif
