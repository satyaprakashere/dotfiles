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

[ -z "$CR_SUGGESTED_OUTPUT_FILE" ] && CR_SUGGESTED_OUTPUT_FILE="$PWD/${CR_FILENAME//./_}"
[ -z "$CR_UNSAVED_DIR" ] && CR_UNSAVED_DIR="$CR_TMPDIR"

if [[ "$PWD" -ef "$CR_UNSAVED_DIR" ]]; then
	go_tmp_dir=true
	# If building an unsaved file, use a separate directory to avoid conflicts.
	rm -rf "$CR_UNSAVED_DIR/Go/" &>/dev/null
	mkdir "$CR_UNSAVED_DIR/Go"
	cp "$CR_FILENAME" "$CR_UNSAVED_DIR/Go/$CR_FILENAME"
	cd "Go"
	CR_FILENAME="Go/$CR_FILENAME"
fi

CR_SUGGESTED_OUTPUT_FILE="${CR_SUGGESTED_OUTPUT_FILE}_${CR_FILENAME##*.}"
CHECKSUM_FILE="$CR_SUGGESTED_OUTPUT_FILE.sha256"
CR_SUGGESTED_OUTPUT_FILE="$CR_SUGGESTED_OUTPUT_FILE.wasm"

if [ -f "$CHECKSUM_FILE" ]; then
	# Check if file matches checksum
	sha256sum -c "$CHECKSUM_FILE" --status
	
	if [ $? -eq 0 ] && [ -f "$CR_SUGGESTED_OUTPUT_FILE" ]; then
		#		echo "File '$FILE' is unchanged. No update needed."
		echo "$CR_SUGGESTED_OUTPUT_FILE"
		exit $status
	fi
	echo "$CR_SUGGESTED_OUTPUT_FILE"
fi

GOOS=js GOARCH=wasm tinygo build -o "$CR_SUGGESTED_OUTPUT_FILE" -target=wasi "$CR_FILENAME" "${@:1}" ${CR_DEBUGGING:+-gcflags "-N -l"}
status=$?
if [ $status -eq 0 ]; then
	if [ "$go_tmp_dir" = true ]; then
		mv -f "$CR_UNSAVED_DIR/Go/"* "$CR_UNSAVED_DIR/"
	fi
	sha256sum "$CR_FILENAME" > "$CHECKSUM_FILE"
	echo "$CR_SUGGESTED_OUTPUT_FILE"
fi
exit $status
