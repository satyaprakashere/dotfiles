#!/bin/bash
# This is a CodeRunner compile script. 
# ... (standard CodeRunner header truncated for brevity in replacement but kept in file)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/cr_build.sh"

export GOEXPERIMENT=arenas

build_command() {
    case "$CR_FILENAME" in
        *.go)   go build -o "$CR_SUGGESTED_OUTPUT_FILE" "$CR_FILENAME" "$@" ${CR_DEBUGGING:+-gcflags "-N -l"} ;;

        *.odin) odin build "$CR_FILENAME" -file "$@" -out="$CR_SUGGESTED_OUTPUT_FILE" ;;

        *.rs)   cratename="$(basename "$CR_SUGGESTED_OUTPUT_FILE" | sed 's/[[:blank:]]/_/g')"
                rustc -o "$CR_SUGGESTED_OUTPUT_FILE" --crate-name "$cratename" "$CR_FILENAME" "$@" ${CR_DEBUGGING:+-g} ;;

        *.cpp)  xcrun clang++ -x c++ -lc++ -o "$CR_SUGGESTED_OUTPUT_FILE" -std=c++23 -Wall -Werror "$CR_FILENAME" "$@"\
                    ${CR_DEBUGGING:+-g} -fno-caret-diagnostics -fno-diagnostics-show-option -fmessage-length=0 ;;

        *.c)    xcrun clang -o "$CR_SUGGESTED_OUTPUT_FILE" -std=c23 -Wall -Werror "$CR_FILENAME" "$@" \
                    ${CR_DEBUGGING:+-g} -fno-caret-diagnostics -fno-diagnostics-show-option -fmessage-length=0 ;;

        *.swift)   xcrun -sdk macosx swiftc -o "$CR_SUGGESTED_OUTPUT_FILE" "$CR_FILENAME" "$@" ${CR_DEBUGGING:+-g};;

        *.zig)  zig build-exe "$CR_FILENAME" -femit-bin="$CR_SUGGESTED_OUTPUT_FILE" "$@" ;;

        *.java) javac "$CR_FILENAME" -d "$CR_TMPDIR" --enable-preview --release 25 -encoding ${enc[$CR_ENCODING]} "$@" ${CR_DEBUGGING:+-g} ;;

        *.hs)   ghc -o "$CR_SUGGESTED_OUTPUT_FILE" -hidir="$CR_TMPDIR" -odir="$CR_TMPDIR" "$CR_FILENAME" "$@" ;;

        *.f90)  gfortran $CR_FILENAME "$@" -o "$CR_SUGGESTED_OUTPUT_FILE" ;;

        *.scm)  gsc -o "$CR_SUGGESTED_OUTPUT_FILE" -exe "$CR_FILENAME" "$@" ;;
        
        *.kt)   export CR_SUGGESTED_OUTPUT_FILE="$CR_SUGGESTED_OUTPUT_FILE.jar"
                kotlinc "$CR_FILENAME" -include-runtime -d "$CR_SUGGESTED_OUTPUT_FILE" "$@" ;;

        *.scala) scalac "$CR_FILENAME" -d "$CR_TMPDIR" "$@" && touch "$CR_SUGGESTED_OUTPUT_FILE" ;;

        *.m)    xcrun clang -o "$CR_SUGGESTED_OUTPUT_FILE" -fobjc-arc -framework Foundation "$CR_FILENAME" "$@" ;;

        #*.py)   python "$CR_FILENAME" "$@" ;;
        #*.js)   node "$CR_FILENAME" "$@" ;;
        #*.ts)   ts-node "$CR_FILENAME" "$@" ;;
        #*.sh)   bash "$CR_FILENAME" "$@" ;;
        #*.rb)   ruby "$CR_FILENAME" "$@" ;;
        *)      echo "No build command defined for this file type: $CR_FILENAME\n"; exit 1 ;;
    esac
}

init_cr
handle_unsaved
check_checksum

build_command "$@"
status=$?

post_build $status
