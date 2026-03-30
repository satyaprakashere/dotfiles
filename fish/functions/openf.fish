function openf
    # Resolve the physical path of the alias/symlink
    set -l target (realpath $(which $argv[1]))

    # Check if the path exists, then open its parent directory
    if test -e $target
        open (dirname $target)
    else
        echo "Error: Could not resolve original file for '$argv[1]'"
    end
end
