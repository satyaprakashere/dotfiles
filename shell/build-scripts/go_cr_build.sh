#!/bin/bash
# This is a CodeRunner compile script. 
# ... (standard CodeRunner header truncated for brevity in replacement but kept in file)

source "$(dirname "$0")/cr_build.sh"

init_cr
handle_unsaved
check_checksum

go build -o "$CR_SUGGESTED_OUTPUT_FILE" "$CR_FILENAME" "${@:1}" ${CR_DEBUGGING:+-gcflags "-N -l"}
status=$?

post_build $status
