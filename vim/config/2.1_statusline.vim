" ----[ lightline settings ]----------
let g:lightline = { 'colorscheme': 'catppuccin_mocha', 'active': { 'left': [ [ 'mode', 'paste' ], [ 'gitbranch', 'readonly', 'filename', 'modified' ] ] }, 'component_function': { 'gitbranch': 'LightLineFugitive', 'filename': 'LightLineFilename', 'mode': 'LightLineMode' } }

function! LightLineModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
  return &ft !~? 'help' && &readonly ? '' : ''
endfunction

function! LightLineFilename()
  let fname = expand('%:t')
  return fname =~ 'NERD_tree' ? '' : ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') . ('' != fname ? fname : '[No Name]') . ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineFugitive()
  try
    if expand('%:t') !~? 'NERD' && exists('*FugitiveHead')
      let branch = FugitiveHead()
      return strlen(branch) ? ' ' . branch : ''
    endif
  catch
  endtry
  return ''
endfunction

function! LightLineMode()
  let fname = expand('%:t')
  return fname =~ 'NERD_tree' ? 'NERDTree' : winwidth(0) > 60 ? lightline#mode() : ''
endfunction
