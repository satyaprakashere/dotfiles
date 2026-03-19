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
CR_SUGGESTED_OUTPUT_FILE="$CR_SUGGESTED_OUTPUT_FILE.js"

output=$(tsc --outFile "$CR_SUGGESTED_OUTPUT_FILE" "$CR_FILENAME" "${@:1}")
status=$?
if [ $status -eq 0 ]; then
	echo "$CR_SUGGESTED_OUTPUT_FILE"
elif [ $status -eq 127 ]; then
	echo -e "\nCould not find TypeScript on your system. TypeScript is installed using npm. If you don't have npm installed, you can get it at https://www.npmjs.com/\nWith npm, you can install TypeScript with the following command:\n\nnpm install -g typescript"
else
	>& 2 echo "$output"
fi
exit $status
