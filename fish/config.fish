if status is-interactive
    # Commands to run in interactive sessions can go here
end

function gs
    git status
end

function ls
    eza
end

function du
    dust
end

function find
    fd
end

function grep
    rg
end

function cat
    bat
end

starship init fish | source

function fish_greeting
    fastfetch
end

