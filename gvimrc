macmenu &Tools.Make key=<nop>
macmenu &Tools.List\ Errors key=<nop>
"autocmd filetype cpp nnoremap<D-b> :<ESC>!clang++ -std=c++11 % -o %:r<Enter>
"autocmd filetype cpp inoremap<D-b> :<ESC>!clang++ -std=c++11 % -o %:r<Enter>
"colorscheme materialbox
set background=dark
