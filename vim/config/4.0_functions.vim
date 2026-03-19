" ----[ Custom Functions ]----------

" C++ Compilation command
command! Compile Shell clang++ -std=c++17 % -o %:r

command! -nargs=? -complete=dir ProjectFiles call s:project_files(<q-args>)

function! s:project_files(dir)
    let l:dir = empty(a:dir) ? s:find_git_root() : a:dir
    let l:opts = {
        \ 'source': 'fd --type f --hidden --follow --exclude .git',
        \ 'options': ['--prompt', fnamemodify(l:dir, ':t') . '> ', 
        \             '--bind', 'ctrl-u:reload(fd --type f --hidden --follow --exclude .git . ' . fnamemodify(l:dir, ':h') . ')']
        \ }
    call fzf#vim#files(l:dir, fzf#vim#with_preview(l:opts), 0)
endfunction

function! s:find_git_root()
    let l:root = systemlist('git rev-parse --show-toplevel')[0]
    return v:shell_error ? getcwd() : l:root
endfunction

" Timing function for commands
function! HowLong(command, numberOfTimes)
    let l:more = &more
    set nomore
    let l:startTime = localtime()
    for i in range(a:numberOfTimes)
        execute a:command
    endfor
    let l:result = localtime() - l:startTime
    let &more = l:more
    return l:result
endfunction

" Run shell command and display output in a scratch buffer
command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)

function! s:RunShellCommand(cmdline)
    let l:expanded_cmdline = a:cmdline
    silent! bw compilation
    for part in split(a:cmdline, ' ')
        if part[0] =~ '\v[%#<]'
            let l:expanded_part = fnameescape(expand(part))
            let l:expanded_cmdline = substitute(l:expanded_cmdline, part, l:expanded_part, '')
        endif
    endfor
    botright new
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    resize 10
    file compilation
    let l:startTime = localtime()
    execute '$read !'. l:expanded_cmdline
    let l:result = localtime() - l:startTime
    echo '[Finished in '.l:result.'s]'
    setlocal nomodifiable
    nnoremap <buffer> q :q<CR>
endfunction

" OpenCV Build command
command! OpencvBuild Shell clang++ -std=c++17 % -o %:r `pkg-config --cflags --libs opencv`
