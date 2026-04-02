#!/bin/bash
# This is a CodeRunner compile script. Compile scripts are used to compile
# code before being run using the run command specified in CodeRunner
# preferences. This script is invoked with the following properties:
#
# Current directory:	The directory of the source file being run
#
# Arguments $1-$n:		User-defined compile flags	
#
# Environment:			$CR_FILENAME	Filename of the source file being run
#						$CR_ENCODING	Encoding code of the source file
#						$CR_TMPDIR		Path of CodeRunner's temporary directory
#
# This script should have the following return values:
# 
# Exit status:			0 on success (CodeRunner will continue and execute run command)
#
# Output (stdout):		On success, one line of text which can be accessed
#						using the $compiler variable in the run command
#
# Output (stderr):		Anything outputted here will be displayed in
#						the CodeRunner console

# Common functions for CodeRunner build and run scripts

# Encoding mapping for CodeRunner

declare -a enc
enc[4]="UTF-8"
enc[0]="MacRoman"
enc[30]="UTF-16"
enc[1]="ISO-8859-1"
enc[3]="EUC-JP"
enc[5]="ISO-2022-JP"
enc[6]="Shift_JIS"
enc[9]="ISO-8859-2"
enc[10]="UTF-16BE"
enc[11]="UTF-16LE"
enc[12]="GBK"
enc[13]="GB18030"
enc[14]="Big5"

# Initialize CodeRunner environment variables
init_cr() {
    # Resolve absolute path for CR_FILENAME if it's relative
    if [[ ! "$CR_FILENAME" = /* ]]; then
        CR_FILENAME="$(pwd)/$CR_FILENAME"
    fi

    # Set default values for unsaved dir and language
    [ -z "$CR_UNSAVED_DIR" ] && CR_UNSAVED_DIR="$CR_TMPDIR"
    [ -z "$LANGUAGE" ] && LANGUAGE="${CR_FILENAME##*.}"

    # Try to find project root to determine output file name
    case "$LANGUAGE" in
        go|mod)  project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "go.mod") || project_root="" ;;
        rs|toml) project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "Cargo.toml") || project_root="" ;;
        zig)     project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "build.zig") || project_root="" ;;
        java|kt|xml|gradle|kts) project_root=$(find_project_root "$(dirname "$CR_FILENAME")" "pom.xml build.gradle build.gradle.kts") || project_root="" ;;
        # ... add others if needed
    esac

    if [[ "$base" == "pom.xml" || "$base" == "build.gradle" || "$base" == "build.gradle.kts" || \
          "$base" == "Cargo.toml" || "$base" == "go.mod" || "$base" == "build.zig" || \
          "$base" == "gleam.toml" || "$base" == "mix.exs" || "$base" == "package.json" || \
          "$base" == "pyproject.toml" || "$base" == "Gemfile" || "$base" == "composer.json" || \
          "$base" == "deps.edn" || "$base" == "project.clj" || "$base" == "bb.edn" || \
          "$base" == *.csproj || "$base" == *.sln ]] || [[ -n "$project_root" ]]; then
        
        # Project-level build result
        local actual_root="${project_root:-$(dirname "$CR_FILENAME")}"
        local dir_name="$(basename "$actual_root")"
        export CR_SUGGESTED_OUTPUT_FILE="$CR_TMPDIR/CodeRunner/${dir_name}_Project"
    else
        # Single-file build result
        export CR_SUGGESTED_OUTPUT_FILE="$CR_TMPDIR/CodeRunner/$(basename "${CR_FILENAME//./_}")"
    fi

    # Ensure the output directory exists
    mkdir -p "$(dirname "$CR_SUGGESTED_OUTPUT_FILE")"

    # Checksum file is used to avoid rebuilding if source hasn't changed
    CHECKSUM_FILE="$CR_SUGGESTED_OUTPUT_FILE.sha256"
}

# Search upward for a project root (e.g. where go.mod or Makefile is)
find_project_root() {
    local start_dir="$1"
    local markers=($2) # Space-separated list of markers
    local current_dir="$start_dir"

    while [[ -n "$current_dir" ]]; do
        [[ "$current_dir" == "/" ]] && break
        for marker in "${markers[@]}"; do
            if [[ -f "$current_dir/$marker" ]] || [[ -d "$current_dir/$marker" ]]; then
                echo "$current_dir"
                return 0
            fi
        done
        [[ "$current_dir" == "." ]] && break
        current_dir="$(dirname "$current_dir")"
    done
    return 1
}

# Discover the first class with a main method in a Maven project
discover_maven_main() {
    local project_root="$1"
    # Search for first class with a main method in src/main/java
    local main_file=$(grep -rl "public static void main" "$project_root/src/main/java" 2>/dev/null | head -n 1)
    if [ -n "$main_file" ]; then
        # Extract package from file
        local package_name=$(grep -m 1 "^package " "$main_file" | sed 's/package \(.*\);/\1/' | tr -d '[:space:]')
        local classname=$(basename "$main_file" .java)
        echo "${package_name:+$package_name.}$classname"
    fi
}

# Handle builds for files that haven't been saved yet (CodeRunner temp files)
handle_unsaved() {
    local lang_dir="$LANGUAGE"
    if [[ "$PWD" -ef "$CR_UNSAVED_DIR" ]]; then
        is_tmp_dir=true
        # If building an unsaved file, use a separate directory to avoid conflicts
        rm -rf "$CR_UNSAVED_DIR/$lang_dir/" &>/dev/null
        mkdir -p "$CR_UNSAVED_DIR/$lang_dir"
        local base_filename="$(basename "$CR_FILENAME")"
        cp "$CR_FILENAME" "$CR_UNSAVED_DIR/$lang_dir/$base_filename"
        cd "$lang_dir"
        CR_FILENAME="$lang_dir/$base_filename"
    fi
}

# Check if a built binary already exists and matches the source checksum
check_checksum() {
    if [ -f "$CHECKSUM_FILE" ]; then
        # Check if current source matches the saved checksum
        sha256sum -c "$CHECKSUM_FILE" --status

        # If it matches and the binary exists, we can skip the build
        if [ $? -eq 0 ] && [ -f "$CR_SUGGESTED_OUTPUT_FILE" ]; then
            echo "$CR_SUGGESTED_OUTPUT_FILE"
            exit 0
        fi
    fi
}

# Create a small executable wrapper for project-based runs.
# This avoids "is a directory" errors in CodeRunner by providing a real script.
create_project_wrapper() {
    local working_dir="$1"
    local run_cmd="$2"
    
    cat <<EOF > "$CR_SUGGESTED_OUTPUT_FILE"
#!/bin/bash
# CodeRunner Project/Interpreted Wrapper
cd "$working_dir"
exec $run_cmd "\$@"
EOF
    chmod +x "$CR_SUGGESTED_OUTPUT_FILE"
}

# Post-build cleanup and artifact management
post_build() {
    local status=$1
    local lang_dir="$LANGUAGE"
    if [ $status -eq 0 ]; then
        # If we were building an unsaved file, move fragments back to the main temp dir
        if [ "$is_tmp_dir" = true ]; then
            mv -f "$CR_UNSAVED_DIR/$lang_dir/"* "$CR_UNSAVED_DIR/"
        fi
        # Create a checksum to enable build caching next time
        sha256sum "$CR_FILENAME" > "$CHECKSUM_FILE"
        # Always output the suggest output path for CodeRunner/build_run.sh to capture
        echo "$CR_SUGGESTED_OUTPUT_FILE"
    fi
    exit $status
}

