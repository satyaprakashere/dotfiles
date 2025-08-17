#!/bin/bash
# This is a CodeRunner compile script. 
# ... (standard CodeRunner header truncated for brevity in replacement but kept in file)

source "$(dirname "$0")/cr_build.sh"

init_cr
handle_unsaved
check_checksum

odin build $CR_FILENAME -file "${@:1}" -out="$CR_SUGGESTED_OUTPUT_FILE"
status=$?

post_build $status
