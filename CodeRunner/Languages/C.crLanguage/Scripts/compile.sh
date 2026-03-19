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

autoinclude=true
for arg in "$@"; do
	if [[ $arg = "-cr-noautoinclude" ]]; then
		autoinclude=false
		continue
	fi
	args+=("$arg");
done;
set -- "${args[@]}"

# CodeRunner autoinclude - automatically links included files
# Disable by using -cr-noautoinclude compile flag
if [ $autoinclude = true ]; then
	filelist=`autoinclude "$PWD/$CR_FILENAME" 2>/dev/null`
	includestatus=$?
	if [ $includestatus -eq 0 ]; then
		# Hacky way of getting bash to interpret the files separated by ':' as distinct arguments
		OIFS="$IFS"
		IFS=':'
		read -a files <<< "${filelist}"
		IFS="$OIFS"
	else
		files=("$CR_FILENAME")
	fi
else
	files=("$CR_FILENAME")
fi

CR_SUGGESTED_OUTPUT_FILE="${CR_SUGGESTED_OUTPUT_FILE}_${CR_FILENAME##*.}"
CHECKSUM_FILE="$CR_SUGGESTED_OUTPUT_FILE.sha256"

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

xcrun clang -v &>/dev/null
s=$?
if [ $s -eq 69 ]; then
	>& 2 echo "Please open Xcode and accept the Developer License Agreement to run C code."
	exit $s
elif [ $s -ne 0 ]; then
	>& 2 echo "To run C code, you need to have developer tools installed. Please choose the \"Install\" option in the dialog that appears, or use the terminal command: xcode-select --install"
	exit $s
fi

xcrun clang -o "$CR_SUGGESTED_OUTPUT_FILE" -std=c23 -Wall -Werror "${files[@]}" "${@:1}" ${CR_DEBUGGING:+-g} -fno-caret-diagnostics -fno-diagnostics-show-option -fmessage-length=0
status=$?

if [ $status -eq 0 ]; then
	sha256sum "$CR_FILENAME" > "$CHECKSUM_FILE"
	echo "$CR_SUGGESTED_OUTPUT_FILE"
fi
exit $status
