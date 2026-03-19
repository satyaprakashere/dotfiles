" ----[ fzf.vim ]----------
let g:fzf_action = { 'ctrl-t': 'tab split', 'ctrl-x': 'split', 'ctrl-v': 'vsplit' }

nnoremap <C-p> :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :GFiles<CR>
nnoremap <leader>t :Tags<CR>

" ----[ EasyMotion ]----------
map <Leader> <Plug>(easymotion-prefix)
nmap <leader>s <Plug>(easymotion-s2)
let g:EasyMotion_smartcase = 1

" ----[ GitGutter ]----------
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '-'

" ----[ Lightline ]----------
let g:lightline = { 'colorscheme': 'catppuccin_mocha', 'active': { 'left': [ [ 'mode', 'paste' ], [ 'gitbranch', 'readonly', 'filename', 'modified' ] ] }, 'component_function': { 'gitbranch': 'FugitiveHead' } }

" ----[ coc.nvim ]----------
let g:coc_node_path = '/usr/local/bin/node' " Ensure this is correct for the user's system

" ----[ Polyglot ]----------
let g:polyglot_disabled = ['c', 'cpp']

" ----[ NERDTree ]----------
nnoremap <leader>n :NERDTreeToggle<CR>
let NERDTreeShowHidden=1

" ----[ Markdown Preview ]----------
let g:mkdp_auto_start = 0

" ----[ Multi-cursor ]----------
" vim-visual-multi uses default mappings (Ctrl-N)
