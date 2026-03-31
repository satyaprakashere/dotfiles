function fish_greeting
    if not set -q __fastfetch_shown
        set -Ux __fastfetch_shown $TTY
        fastfetch
    end
end

function cdf
    set target (osascript -e '
        tell application "Finder"
            if (count of Finder windows) is not 0 then
                set thePath to (POSIX path of (target of front window as alias))
                return thePath
            else
                return ""
            end if
        end tell
    ')
    if test -n "$target"
        cd "$target"
    else
        echo "No Finder window is open."
    end
end

function zigr
    zig run -ODebug $argv[1]
end

function ktr
    kotlin $argv[1]
end

function cljr
    set ns $argv[1]
    clojure -Sdeps '{:paths ["."]}' -M  $ns
end

function crun
    if test (count $argv) -lt 1
        echo "Usage: crun <filename.carbon>"
        return 1
    end

    set filename (basename $argv[1] .carbon)
    carbon compile $filename.carbon
    if test $status -ne 0
        echo "Compilation failed"
        return 1
    end

    carbon link --output=$filename $filename.o
    if test $status -ne 0
        echo "Linking failed"
        return 1
    end

    ./$filename
end

#function run
    #set file (basename (pwd))
    #set filename (status current-filename)
    #set filepath (realpath $argv[1])

    #if test -z "$argv"
        #echo "Usage: run <file>"
        #return 1
    #end

    #switch (string split -r -m1 . $argv[1])[-1]
        #case py
            #python3 $argv[1]
        #case rs
            #rustc $argv[1] -o /tmp/rust_out && /tmp/rust_out
        #case c
            #gcc $argv[1] -o /tmp/c_out && /tmp/c_out
        #case cpp
            #g++ $argv[1] -o /tmp/cpp_out && /tmp/cpp_out
        #case go
            #go run $argv[1]
        #case js
            #node $argv[1]
        #case ts
            #deno run $argv[1]
        #case sh
            #bash $argv[1]
        #case swift
            #swift $argv[1]
        #case kt
            #kotlinc $argv[1] -include-runtime -d /tmp/out.jar && java -jar /tmp/out.jar
        #case java
            #bash -c 'java $0' $argv[1]
        #case go
            #go run $argv[1]
        #case hs
            #runhaskell $argv[1]
        #case zig
            #zig run $argv[1]
        #case clj
            #clojure -Sdeps '{:paths ["."]}' -M $argv[1]
        #case '*'
            #echo "Unsupported file type"
            #return 1
    #end
#end
