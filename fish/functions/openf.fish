function openf --description 'Open the parent directory of a command/binary in Finder'
    if test (count $argv) -eq 0
        echo "Usage: openf <command>"
        return 1
    end

    # Resolve binary path
    set -l bin (which $argv[1] 2>/dev/null)
    if test -z "$bin"
        echo "Error: Command '$argv[1]' not found"
        return 1
    end

    # Resolve the physical path of the alias/symlink
    set -l target (realpath $bin)

    # Check if the path exists, then open its parent directory
    if test -e "$target"
        open (dirname "$target")
    else
        echo "Error: Could not resolve original file for '$argv[1]'"
        return 1
    end
end
