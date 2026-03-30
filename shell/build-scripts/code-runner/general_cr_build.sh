#!/bin/bash
# This is a CodeRunner compile script. 
# ... (standard CodeRunner header truncated for brevity in replacement but kept in file)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/cr_build.sh"

export GOEXPERIMENT=arenas

# Helper functions for each file type
build_go() {
    project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "go.mod")
    if [ -n "$project_root" ]; then
        (cd "$project_root" && go build -o "$CR_SUGGESTED_OUTPUT_FILE" .)
    else
        go build -o "$CR_SUGGESTED_OUTPUT_FILE" "$CR_FILENAME" "$@" ${CR_DEBUGGING:+-gcflags "-N -l"}
    fi
}

build_odin() {
    project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "Makefile ols.json")
    if [ -n "$project_root" ]; then
        if [ -f "$project_root/Makefile" ]; then
            (cd "$project_root" && make)
        else
            odin build "$project_root" -out="$CR_SUGGESTED_OUTPUT_FILE" "$@"
        fi
    else
        odin build "$CR_FILENAME" -file "$@" -out="$CR_SUGGESTED_OUTPUT_FILE"
    fi
    # Ensure the output file exists for build_run.sh check
    touch "$CR_SUGGESTED_OUTPUT_FILE"
}

build_rust() {
    cratename="$(basename "$CR_SUGGESTED_OUTPUT_FILE" | sed 's/[[:blank:]]/_/g')"
    rustc -o "$CR_SUGGESTED_OUTPUT_FILE" --crate-name "$cratename" "$CR_FILENAME" "$@" ${CR_DEBUGGING:+-g}
}

build_cpp() {
    xcrun clang++ -x c++ -lc++ -o "$CR_SUGGESTED_OUTPUT_FILE" -std=c++23 -Wall -Werror "$CR_FILENAME" "$@" \
        ${CR_DEBUGGING:+-g} -fno-caret-diagnostics -fno-diagnostics-show-option -fmessage-length=0
}

build_c() {
    xcrun clang -o "$CR_SUGGESTED_OUTPUT_FILE" -std=c23 -Wall -Werror "$CR_FILENAME" "$@" \
        ${CR_DEBUGGING:+-g} -fno-caret-diagnostics -fno-diagnostics-show-option -fmessage-length=0
}

build_swift() {
    xcrun -sdk macosx swiftc -o "$CR_SUGGESTED_OUTPUT_FILE" "$CR_FILENAME" "$@" ${CR_DEBUGGING:+-g}
}

build_zig() {
    zig build-exe "$CR_FILENAME" -femit-bin="$CR_SUGGESTED_OUTPUT_FILE" "$@"
}

build_java() {
    # Java: handles both single-file and project-based (Maven/Gradle) builds
    project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "pom.xml build.gradle build.gradle.kts")
    if [ -n "$project_root" ]; then
        local encoding_flag=""
        [ -n "${enc[$CR_ENCODING]}" ] && encoding_flag="-Dproject.build.sourceEncoding=${enc[$CR_ENCODING]}"

        if [ -f "$project_root/pom.xml" ]; then
            (cd "$project_root" && mvn compile $encoding_flag)
        elif [ -f "$project_root/build.gradle" ] || [ -f "$project_root/build.gradle.kts" ]; then
            if [ -f "$project_root/gradlew" ]; then
                (cd "$project_root" && ./gradlew classes)
            else
                (cd "$project_root" && gradle classes)
            fi
        fi
        touch "$CR_SUGGESTED_OUTPUT_FILE"
        # Output classpath:mainclassname for build_run.sh
        echo "$(cd "$project_root" && pwd)/target/classes:$(cd "$project_root" && pwd)/build/classes/java/main:$(basename "$CR_FILENAME" .java)"
        exit 0
    else
        # Single-file javac with preview features and specific encoding
        javac "$CR_FILENAME" -d "$(dirname "$CR_SUGGESTED_OUTPUT_FILE")" --enable-preview --release 25 -encoding "${enc[$CR_ENCODING]:-UTF-8}" "$@" ${CR_DEBUGGING:+-g}
        echo "$(dirname "$CR_SUGGESTED_OUTPUT_FILE"):$(basename "$CR_FILENAME" .java)"
        exit 0
    fi
}

build_kotlin() {
    # Kotlin: similar to Java, handles Maven/Gradle projects
    project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "pom.xml build.gradle build.gradle.kts")
    if [ -n "$project_root" ]; then
        local encoding_flag=""
        [ -n "${enc[$CR_ENCODING]}" ] && encoding_flag="-Dproject.build.sourceEncoding=${enc[$CR_ENCODING]}"

        if [ -f "$project_root/pom.xml" ]; then
            (cd "$project_root" && mvn compile $encoding_flag)
        elif [ -f "$project_root/build.gradle" ] || [ -f "$project_root/build.gradle.kts" ]; then
            if [ -f "$project_root/gradlew" ]; then
                (cd "$project_root" && ./gradlew classes)
            else
                (cd "$project_root" && gradle classes)
            fi
        fi
        touch "$CR_SUGGESTED_OUTPUT_FILE"
        # Output classpath:mainclassname for build_run.sh
        # Kotlin capitalizes the first letter of the filename for the class facade
        local base_name=$(basename "$CR_FILENAME" .kt)
        local first_letter=$(echo "${base_name:0:1}" | tr '[:lower:]' '[:upper:]')
        local class_name="${first_letter}${base_name:1}Kt"
        echo "$(cd "$project_root" && pwd)/target/classes:$(cd "$project_root" && pwd)/build/classes/kotlin/main:$class_name"
        exit 0
    else
        # Single-file kotlinc with runtime included
        export CR_SUGGESTED_OUTPUT_FILE="$CR_SUGGESTED_OUTPUT_FILE.jar"
        kotlinc "$CR_FILENAME" -include-runtime -d "$CR_SUGGESTED_OUTPUT_FILE" "$@"
        # Kotlin capitalizes the first letter of the filename for the class facade
        local base_name=$(basename "$CR_FILENAME" .kt)
        local first_letter=$(echo "${base_name:0:1}" | tr '[:lower:]' '[:upper:]')
        local class_name="${first_letter}${base_name:1}Kt"
        echo "$CR_SUGGESTED_OUTPUT_FILE:$class_name"
        exit 0
    fi
}

build_scala() {
    # Scala: single-file compilation with scalac
    scalac "$CR_FILENAME" -d "$(dirname "$CR_SUGGESTED_OUTPUT_FILE")" "$@" && touch "$CR_SUGGESTED_OUTPUT_FILE"
}

build_objc() {
    # Objective-C: compiled with ARC and Foundation framework
    xcrun clang -o "$CR_SUGGESTED_OUTPUT_FILE" -fobjc-arc -framework Foundation "$CR_FILENAME" "$@"
}

build_command() {
    case "$CR_FILENAME" in
        *.go)    build_go "$@" ;;
        *.odin)  build_odin "$@" ;;
        *.rs)    build_rust "$@" ;;
        *.cpp)   build_cpp "$@" ;;
        *.c)     build_c "$@" ;;
        *.swift) build_swift "$@" ;;
        *.zig)   build_zig "$@" ;;
        *.java)  build_java "$@" ;;
        *.kt)    build_kotlin "$@" ;;
        *.scala) build_scala "$@" ;;
        *.m)     build_objc "$@" ;;
        *)      echo "No build command defined for this file type: $CR_FILENAME"; exit 1 ;;
    esac
}

# 1. Initialize CodeRunner environment and output paths
init_cr

# 2. Handle unsaved files (copy to temp if needed)
handle_unsaved

# 3. Check if the file matches a previous successful build (checksum)
check_checksum

# 4. Run the language-specific build command
build_command "$@"
status=$?

# 5. Post-build cleanup and output the result path for build_run.sh
post_build $status
