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

[ -z "$CR_SUGGESTED_OUTPUT_FILE" ] && CR_SUGGESTED_OUTPUT_FILE="$PWD/${CR_FILENAME%.*}"
[ "$CR_SUGGESTED_OUTPUT_FILE" != "/dev/null" ] && CR_SUGGESTED_OUTPUT_FILE="$CR_SUGGESTED_OUTPUT_FILE.jar"

kotlinc "$CR_FILENAME" -include-runtime -d "$CR_SUGGESTED_OUTPUT_FILE" "${@:1}"

status=$?
if [ $status -eq 0 ]; then
	echo "$CR_SUGGESTED_OUTPUT_FILE"
elif [ $status -eq 127 ]; then
	echo -e "\nTo run Kotlin code, you need to have the Kotlin compiler installed. You can get it at https://kotlinlang.org/"
fi
exit $status
