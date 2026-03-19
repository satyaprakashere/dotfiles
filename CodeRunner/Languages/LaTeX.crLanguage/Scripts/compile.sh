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

PATH="$PATH:/usr/texbin:/Library/TeX/texbin:/Library/TeX/Distributions/Programs/texbin"
[ -z "$CR_SUGGESTED_OUTPUT_FILE" ] && CR_SUGGESTED_OUTPUT_FILE="$PWD/${CR_FILENAME%.*}"
CR_SUGGESTED_OUTPUT_FILE="$CR_SUGGESTED_OUTPUT_FILE.pdf"

output="$(pdflatex -halt-on-error -output-directory="$(dirname "$CR_SUGGESTED_OUTPUT_FILE")" "$CR_FILENAME" "${@:1}")"

status=$?
if [ $status -eq 0 ]; then
	file="$CR_SUGGESTED_OUTPUT_FILE"
	if [ -f "$file" ]; then
		localfile="$PWD/${CR_FILENAME%.*}.pdf"
		if [ ! "$file" -ef "$localfile" ]; then
			# Move the resulting pdf file to the local directory
			if mv -f "$file" "$localfile" 2>/dev/null; then
				file="$localfile"
			fi
		fi
	fi
	echo "$file"
else
	>& 2 echo "$output"
fi
exit $status
