#!/bin/bash
# This is a CodeRunner compile script. 
# ... (standard CodeRunner header truncated for brevity in replacement but kept in file)

# Resolve the real path of the script even if it's a symlink or an alias
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

source "$SCRIPT_DIR/cr_build.sh"

# Helper functions for each file type
build_go() {
    export GOEXPERIMENT=arenas
    project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "go.mod")
    if [ -n "$project_root" ]; then
        (cd "$project_root" && go build .)
        create_project_wrapper "$project_root" "go run ."
    else
        go build -o "$CR_SUGGESTED_OUTPUT_FILE" "$CR_FILENAME" "$@" ${CR_DEBUGGING:+-gcflags "-N -l"}
    fi
}

build_odin() {
    project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "Makefile ols.json")
    if [ -n "$project_root" ]; then
        if [ -f "$project_root/Makefile" ]; then
            (cd "$project_root" && make)
            create_project_wrapper "$project_root" "make run"
        else
            odin build "$project_root" -out="$CR_SUGGESTED_OUTPUT_FILE" "$@"
            create_project_wrapper "$project_root" "odin run ."
        fi
    else
        odin build "$CR_FILENAME" -file "$@" -out="$CR_SUGGESTED_OUTPUT_FILE"
        # Ensure the output file exists for build_run.sh check
        touch "$CR_SUGGESTED_OUTPUT_FILE"
    fi
}

build_rust() {
    project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "Cargo.toml")
    if [ -n "$project_root" ]; then
        (cd "$project_root" && cargo build)
        create_project_wrapper "$project_root" "cargo run --quiet"
    else
        cratename="$(basename "$CR_SUGGESTED_OUTPUT_FILE" | sed 's/[[:blank:]]/_/g')"
        rustc -o "$CR_SUGGESTED_OUTPUT_FILE" --crate-name "$cratename" "$CR_FILENAME" "$@" ${CR_DEBUGGING:+-g}
    fi
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
    project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "build.zig")
    if [ -n "$project_root" ]; then
        (cd "$project_root" && zig build "$@")
        create_project_wrapper "$project_root" "zig build run"
    else
        zig build-exe "$CR_FILENAME" -femit-bin="$CR_SUGGESTED_OUTPUT_FILE" "$@"
    fi
}

build_java() {
    # Java: handles both single-file and project-based (Maven/Gradle) builds
    project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "pom.xml build.gradle build.gradle.kts")
    if [ -n "$project_root" ]; then
        local package_name=$(grep -m 1 "^package " "$CR_FILENAME" | sed 's/package \(.*\);/\1/' | tr -d '[:space:]')
        local classname="$(basename "$CR_FILENAME" .java)"
        local full_classname="${package_name:+$package_name.}$classname"
        
        if [ -f "$project_root/pom.xml" ]; then
            if grep -q "quarkus" "$project_root/pom.xml"; then
                create_project_wrapper "$project_root" "mvn quarkus:dev"
            elif grep -q "spring-boot" "$project_root/pom.xml"; then
                create_project_wrapper "$project_root" "mvn spring-boot:run"
            elif grep -qE "public static void main\(" "$CR_FILENAME"; then
                create_project_wrapper "$project_root" "mvn exec:java -Dexec.mainClass=\"$full_classname\""
            else
                # Discovery fallback
                local discovered_main=$(discover_maven_main "$project_root")
                if [ -n "$discovered_main" ]; then
                    create_project_wrapper "$project_root" "mvn exec:java -Dexec.mainClass=\"$discovered_main\""
                else
                    create_project_wrapper "$project_root" "mvn exec:java"
                fi
            fi
        elif [ -f "$project_root/build.gradle" ] || [ -f "$project_root/build.gradle.kts" ]; then
            local gradlew="./gradlew"
            [ ! -f "$project_root/gradlew" ] && gradlew="gradle"
            create_project_wrapper "$project_root" "$gradlew run"
        fi
    else
        # Single-file javac with preview features and specific encoding
        javac "$CR_FILENAME" -d "$(dirname "$CR_SUGGESTED_OUTPUT_FILE")" --enable-preview --release 25 -encoding "${enc[$CR_ENCODING]:-UTF-8}" "$@" ${CR_DEBUGGING:+-g}
        local classpath="$(dirname "$CR_SUGGESTED_OUTPUT_FILE")"
        local package_name=$(grep -m 1 "^package " "$CR_FILENAME" | sed 's/package \(.*\);/\1/' | tr -d '[:space:]')
        local classname="$(basename "$CR_FILENAME" .java)"
        local full_classname="${package_name:+$package_name.}$classname"
        
        create_project_wrapper "$(dirname "$CR_FILENAME")" "java --enable-preview -cp \"$classpath\" \"$full_classname\""
    fi
}

build_kotlin() {
    # Kotlin: similar to Java, handles Maven/Gradle projects
    project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "pom.xml build.gradle build.gradle.kts")
    if [ -n "$project_root" ]; then
        local package_name=$(grep -m 1 "^package " "$CR_FILENAME" | sed 's/package \(.*\)/\1/' | tr -d '[:space:]')
        local base_name=$(basename "$CR_FILENAME" .kt)
        local first_letter=$(echo "${base_name:0:1}" | tr '[:lower:]' '[:upper:]')
        local class_name="${first_letter}${base_name:1}Kt"
        local full_classname="${package_name:+$package_name.}$class_name"

        if [ -f "$project_root/pom.xml" ]; then
            if grep -q "quarkus" "$project_root/pom.xml"; then
                create_project_wrapper "$project_root" "mvn quarkus:dev"
            elif grep -q "spring-boot" "$project_root/pom.xml"; then
                create_project_wrapper "$project_root" "mvn spring-boot:run"
            elif grep -qE "fun main\(" "$CR_FILENAME"; then
                create_project_wrapper "$project_root" "mvn exec:java -Dexec.mainClass=\"$full_classname\""
            else
                create_project_wrapper "$project_root" "mvn exec:java"
            fi
        elif [ -f "$project_root/build.gradle" ] || [ -f "$project_root/build.gradle.kts" ]; then
            local gradlew="./gradlew"
            [ ! -f "$project_root/gradlew" ] && gradlew="gradle"
            create_project_wrapper "$project_root" "$gradlew run"
        fi
    else
        # Single-file kotlinc with runtime included
        local jar_file="$CR_SUGGESTED_OUTPUT_FILE.jar"
        kotlinc "$CR_FILENAME" -include-runtime -d "$jar_file" "$@"
        create_project_wrapper "$(dirname "$CR_FILENAME")" "java -jar \"$jar_file\""
    fi
}

build_scala() {
    # Scala: single-file compilation with scalac
    scalac "$CR_FILENAME" -d "$(dirname "$CR_SUGGESTED_OUTPUT_FILE")" "$@"
    local classpath="$(dirname "$CR_SUGGESTED_OUTPUT_FILE")"
    local class_name=$(basename "$CR_FILENAME" .scala)
    create_project_wrapper "$(dirname "$CR_FILENAME")" "scala --classpath \"$classpath\" --main-class \"$class_name\" --"
}

build_objc() {
    # Objective-C: compiled with ARC and Foundation framework
    xcrun clang -o "$CR_SUGGESTED_OUTPUT_FILE" -fobjc-arc -framework Foundation "$CR_FILENAME" "$@"
}

build_maven() {
    # Maven: project build/run from pom.xml
    local project_root=$(dirname "$CR_FILENAME")
    if grep -q "quarkus" "$project_root/pom.xml"; then
        create_project_wrapper "$project_root" "mvn quarkus:dev"
    elif grep -q "spring-boot" "$project_root/pom.xml"; then
        create_project_wrapper "$project_root" "mvn spring-boot:run"
    else
        local discovered_main=$(discover_maven_main "$project_root")
        if [ -n "$discovered_main" ]; then
            create_project_wrapper "$project_root" "mvn exec:java -Dexec.mainClass=\"$discovered_main\""
        else
            (cd "$project_root" && mvn compile)
            create_project_wrapper "$project_root" "mvn exec:java"
        fi
    fi
}

build_gradle() {
    # Gradle: project build/run from build.gradle
    local project_root=$(dirname "$CR_FILENAME")
    local gradlew="./gradlew"
    [ ! -f "$project_root/gradlew" ] && gradlew="gradle"
    (cd "$project_root" && $gradlew classes)
    create_project_wrapper "$project_root" "$gradlew run"
}

build_gleam() {
    # Gleam: project-based build using gleam.toml
    project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "gleam.toml")
    if [ -n "$project_root" ]; then
        (cd "$project_root" && gleam build)
        create_project_wrapper "$project_root" "gleam run"
    else
        echo "Error: Gleam project not found (gleam.toml missing)." >&2
        exit 1
    fi
}

build_elixir() {
    # Elixir: check for mix.exs project root
    project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "mix.exs")
    if [ -n "$project_root" ]; then
        (cd "$project_root" && mix compile)
        create_project_wrapper "$project_root" "mix run"
    else
        # Single-file elixirc with wrapper execution
        local out_dir="$(dirname "$CR_SUGGESTED_OUTPUT_FILE")"
        mkdir -p "$out_dir"
        elixirc -o "$out_dir" "$CR_FILENAME"
        create_project_wrapper "$(dirname "$CR_FILENAME")" "elixir -pa $out_dir $(basename "$CR_FILENAME")"
    fi
}

build_haskell() {
    # Haskell: handles Stack, Cabal, and standalone GHC builds
    project_root_stack=$(find_project_root "$(dirname "$CR_FILENAME")" "stack.yaml")
    project_root_cabal=$(find_project_root "$(dirname "$CR_FILENAME")" "cabal.project")

    # If no cabal.project, look for .cabal files manually
    if [ -z "$project_root_cabal" ]; then
        local current_dir="$(dirname "$CR_FILENAME")"
        while [[ "$current_dir" != "/" ]]; do
            if ls "$current_dir"/*.cabal &>/dev/null; then
                project_root_cabal="$current_dir"
                break
            fi
            current_dir="$(dirname "$current_dir")"
        done
    fi

    if [ -n "$project_root_stack" ]; then
        (cd "$project_root_stack" && stack build)
        create_project_wrapper "$project_root_stack" "stack run"
    elif [ -n "$project_root_cabal" ]; then
        (cd "$project_root_cabal" && cabal build)
        create_project_wrapper "$project_root_cabal" "cabal run"
    else
        # Standalone file: use runghc through a wrapper
        create_project_wrapper "$(dirname "$CR_FILENAME")" "runghc $(basename "$CR_FILENAME")"
    fi
}

build_nodejs() {
    # Node.js: support package.json scripts and standalone files
    local project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "package.json")
    if [ -n "$project_root" ]; then
        if grep -q '"start":' "$project_root/package.json"; then
            create_project_wrapper "$project_root" "npm start"
        else
            create_project_wrapper "$project_root" "node $(basename "$CR_FILENAME")"
        fi
    else
        create_project_wrapper "$(dirname "$CR_FILENAME")" "node $(basename "$CR_FILENAME")"
    fi
}

build_python() {
    # Python: support project markers and standalone files
    local project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "pyproject.toml requirements.txt")
    if [ -n "$project_root" ]; then
        create_project_wrapper "$project_root" "python3 $(basename "$CR_FILENAME")"
    else
        create_project_wrapper "$(dirname "$CR_FILENAME")" "python3 $(basename "$CR_FILENAME")"
    fi
}

build_dotnet() {
    # C# / .NET: support project-based build/run
    local project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "*.csproj *.sln")
    if [ -n "$project_root" ]; then
        (cd "$project_root" && dotnet build)
        create_project_wrapper "$project_root" "dotnet run"
    else
        create_project_wrapper "$(dirname "$CR_FILENAME")" "dotnet run"
    fi
}

build_ruby() {
    # Ruby: support Gemfile and standalone files
    local project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "Gemfile")
    if [ -n "$project_root" ]; then
        create_project_wrapper "$project_root" "bundle exec ruby $(basename "$CR_FILENAME")"
    else
        create_project_wrapper "$(dirname "$CR_FILENAME")" "ruby $(basename "$CR_FILENAME")"
    fi
}

build_php() {
    # PHP: support Laravel Artisan and standalone files
    local project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "composer.json artisan")
    if [ -n "$project_root" ]; then
        if [ -f "$project_root/artisan" ]; then
            create_project_wrapper "$project_root" "php artisan serve"
        else
            create_project_wrapper "$project_root" "php $(basename "$CR_FILENAME")"
        fi
    else
        create_project_wrapper "$(dirname "$CR_FILENAME")" "php $(basename "$CR_FILENAME")"
    fi
}

build_shell() {
    # Shell: run using the appropriate shell
    local shell="bash"
    [[ "$CR_FILENAME" == *.fish ]] && shell="fish"
    [[ "$CR_FILENAME" == *.zsh ]] && shell="zsh"
    create_project_wrapper "$(dirname "$CR_FILENAME")" "$shell $(basename "$CR_FILENAME")"
}

build_clojure() {
    # Clojure: handles deps.edn, project.clj, and bb.edn projects or single files
    project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "deps.edn project.clj bb.edn")
    if [ -n "$project_root" ]; then
        if [ -f "$project_root/deps.edn" ]; then
            # If the filename itself is deps.edn, just run clojure
            if [[ "$(basename "$CR_FILENAME")" == "deps.edn" ]]; then
                create_project_wrapper "$project_root" "clojure"
            else
                # Run the specific file within the project context
                local rel_path=$(python3 -c "import os, sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))" "$CR_FILENAME" "$project_root")
                create_project_wrapper "$project_root" "clojure -M \"$rel_path\""
            fi
        elif [ -f "$project_root/project.clj" ]; then
            create_project_wrapper "$project_root" "lein run"
        elif [ -f "$project_root/bb.edn" ]; then
            create_project_wrapper "$project_root" "bb run"
        fi
    else
        # Single file
        if [[ "$(basename "$CR_FILENAME")" == *.cljs ]]; then
             # ClojureScript single file: use clojure -M -m cljs.main
             create_project_wrapper "$(dirname "$CR_FILENAME")" "clojure -M -m cljs.main \"$(basename "$CR_FILENAME")\""
        else
             # Clojure single file (prefer bb if available, fallback to clojure)
             if command -v bb >/dev/null 2>&1; then
                 create_project_wrapper "$(dirname "$CR_FILENAME")" "bb \"$(basename "$CR_FILENAME")\""
             else
                 create_project_wrapper "$(dirname "$CR_FILENAME")" "clojure -M \"$(basename "$CR_FILENAME")\""
             fi
        fi
    fi
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
        *.gleam) build_gleam "$@" ;;
        *.ex|*.exs|mix.exs|*/mix.exs) build_elixir "$@" ;;
        *.hs|*.lhs) build_haskell "$@" ;;
        *.clj|*.cljs|*.cljc|*.edn|deps.edn|*/deps.edn|project.clj|*/project.clj|bb.edn|*/bb.edn) build_clojure "$@" ;;
        pom.xml|*/pom.xml) build_maven "$@" ;;
        build.gradle|*/build.gradle|build.gradle.kts|*/build.gradle.kts) build_gradle "$@" ;;
        *.js|*.ts|package.json|*/package.json) build_nodejs "$@" ;;
        *.py|pyproject.toml|*/pyproject.toml) build_python "$@" ;;
        *.cs|*.csproj|*/BUILD_ARTIFACT.csproj|*.sln|*/BUILD_ARTIFACT.sln) build_dotnet "$@" ;;
        *.rb|Gemfile|*/Gemfile) build_ruby "$@" ;;
        *.php|composer.json|*/composer.json) build_php "$@" ;;
        *.sh|*.fish|*.zsh) build_shell "$@" ;;
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
