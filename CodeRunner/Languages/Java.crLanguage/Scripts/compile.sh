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

enc[4]="UTF8"			# UTF-8
enc[10]="UTF16"			# UTF-16
enc[5]="ISO8859-1"		# ISO Latin 1
enc[9]="ISO8859-2"		# ISO Latin 2
enc[30]="MacRoman"		# Mac OS Roman
enc[12]="CP1252"		# Windows Latin 1
enc[3]="EUCJIS"			# Japanese (EUC)
enc[8]="SJIS"			# Japanese (Shift JIS)
enc[1]="ASCII"			# ASCII

directory=`dirname "$0"`

# Check if file resides in a folder with package name, if so, change directory
package=`"$CR_DEVELOPER_DIR/bin/parsejava" --package "$PWD/$CR_FILENAME" 2>/dev/null`
if [ $? -eq 0 ] && [ ${#package} -ne 0 ]; then
	# Check if package name is in the form package.subpackage.subpackage
	# If this structure matches directory structure, change directory...
	packageDirectory=`echo "$package" | sed 's/\./\//g'`
	if [[ $PWD == *"$packageDirectory" ]]; then
		cd "${PWD:0:${#PWD}-${#packageDirectory}}"
		CR_FILENAME="$packageDirectory"/"$CR_FILENAME"
	else
		if [[ $package == *.* ]]; then
			errmessage="structure"
		else
			errmessage="named"
		fi
			>& 2 echo "CodeRunner Warning: Java file \"$CR_FILENAME\" with package \"$package\" should reside in folder $errmessage \"$packageDirectory\"."
	fi
	if [ ! -z $CR_SANDBOXED ] && [ ! -r "$PWD" ]; then
		exit 56 # CodeRunner will request file system access
	fi
elif [ ! -z $CR_SANDBOXED ] && [ ! -r "$PWD" ]; then
	tmp="$CR_TMPDIR/java"
	rm -r "$tmp" &>/dev/null
	mkdir "$tmp"
	cp "$PWD/$CR_FILENAME" "$tmp/$CR_FILENAME"
	cd "$tmp"
fi


CHECKSUM_FILE="$CR_SUGGESTED_OUTPUT_FILE.sha256"
CR_SUGGESTED_OUTPUT_FILE="$CR_SUGGESTED_OUTPUT_FILE.class"

if [ -f "$CHECKSUM_FILE" ]; then
	# Check if file matches checksum
	sha256sum -c "$CHECKSUM_FILE" --status
	
	if [ $? -eq 0 ] && [ -f "$CR_SUGGESTED_OUTPUT_FILE" ]; then
		echo "File '$FILE' is unchanged. No update needed."
		out=$CR_TMPDIR:${CR_FILENAME%.*}
		echo $out
		exit $status
	fi
fi

javac "$CR_FILENAME" -d "$CR_TMPDIR" --enable-preview --release 25 -encoding ${enc[$CR_ENCODING]} "${@:1}" ${CR_DEBUGGING:+-g}
status=$?

if [ $status -ne 0 ]; then
	version="$(javac -version 2>&1)"
	if [ $? -ne 0 ]; then
		echo -e "\nTo run Java code, you need to install a JDK. You can download a JDK at https://www.oracle.com/java/technologies/javase-downloads.html\n"
		if [[ "$(sw_vers -productVersion)" =~ ^10.(11|12|13|14).* ]]; then
			echo "If you see a system prompt asking you to install Java Runtime, and not a JDK, use the link above to download a JDK rather than installing through the system prompt."
		elif [ ! -z $CR_SANDBOXED ] && [[ ! "$version" =~ "requesting install" ]]; then
			exit 56
		fi
	fi
	exit $status
fi


# Use parsejava to get package and class name of main function.
#out=`"$CR_DEVELOPER_DIR/bin/parsejava" "$PWD/$CR_FILENAME" 2>/dev/null`
#status=$?
#if [ $status -ne 0 ]; then
#	>& 2 echo "CodeRunner Warning: Could not find a main method in the file \"$CR_FILENAME\". Please add a main method or run the file in your project containing your main method."
#	compname=`echo "$CR_FILENAME" | sed 's/\(.*\)\..*/\1/'`
#	if [ -z "$out" ]; then
#		out="$compname"
#	else
#		out="$out.$compname"
#	fi
#fi
out=$CR_TMPDIR:${CR_FILENAME%.*}
sha256sum "$CR_FILENAME" > "$CHECKSUM_FILE"
echo $out
#echo "{$CR_TMPDIR}:$out"
#echo $CR_FILENAME
#echo $PWD
#echo $CHECKSUM_FILE
#echo "{$CR_TMPDIR}:${CR_FILENAME%.*}"
