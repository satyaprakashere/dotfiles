"----[Custom Funtions for adding new Functionality]----------------------------------------------

    command! Compile Shell clang++ -std=c++14 % -o %:r
    " Times the number of times a particular command takes to execute the specified
    " number of times (in seconds).
    function! HowLong( command, numberOfTimes )
        " We don't want to be prompted by a message if the command being tried is
        " an echo as that would slow things down while waiting for user input.
        let more = &more
        set nomore
        let startTime = localtime()
        for i in range( a:numberOfTimes )
            execute a:command
        endfor
        let result = localtime() - startTime
        let &more = more
        return result
    endfunction

    " Custom Shell command for executing shell function in a different frame.
    command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)

    function! s:RunShellCommand(cmdline)
        echo a:cmdline
        let expanded_cmdline = a:cmdline
        silent! bw compilation
        "buffer [Scratch]
        "q
        for part in split(a:cmdline, ' ')
            if part[0] =~ '\v[%#<]'
                let expanded_part = fnameescape(expand(part))
                let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
            endif
        endfor
        botright new
        set buflisted
        setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
        resize 10
        "call setline(1, 'You entered:    ' . a:cmdline)
        "call setline(2, 'Expanded Form:  ' .expanded_cmdline)
        file compilation
        let startTime = localtime()
        execute '$read !'. expanded_cmdline
        let result = localtime() - startTime
        echo '[Finished in '.result.'s]'
        "call setline(2,substitute(getline(2),'.','=','g')
        setlocal nomodifiable
        nnoremap q :q<CR>
    endfunction

    command! OpencvBuild Shell clang++ -std=c++11 % -o %:r `pkg-config --cflags --libs opencv`
"--------------------------------------------------
