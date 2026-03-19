#!/bin/bash
#
# This is a CodeRunner debugger script. CodeRunner uses this script to set up a debug
# session, in addition to mapping commands to those used by a specific debugger.
# 
# When starting a debug session, the script is invoked exactly once with the option
# "debugger-server" and thereafter once with the option "debugger-client". With the
# option "debugger-server", the script should establish the debugging session, with
# stdin/stdout being that of the program being run. With the option "debugger-client",
# the script should connect to the already running debugger-server instance, and here
# stdin/stdout is used to interface with the debugger, using various commands.
# 
# The script will be called with the following arguments:
#
# Running the code/debugger:
# 
#	debugger-server		Establish a debug session.
#	debugger-client		Establish a shell connection to the debugger-server instance.
#
# Regular expressions used in debugging:
#
#	prompt-pattern		Output a regex for the prompt string used by the debugger.
#	message-pattern		Optionally output a regex that if matched by an output line
#						from the debugger-client, is displayed in CodeRunner's console.
#	termination-pattern	Optionally output a regex that matches a termination message.
#						Use the regex's first capture group for the exit status.
#	ignore-pattern		Optionally output a regex that if matched by an output line from the
#						debugger-server, prevents the line from being sent to the console.
#
# Commands used to interface with the debugger:
#
#	launch				Output the command used to launch the debugged program after setup.
#	continue			Output the command used to continue execution of a paused program.
#	pause				Output the command used to pause or interrupt execution.
#	breakpoint-set		Output the command used to set a breakpoint in file $2 at line $3.
#	breakpoint-clear	Output the command used to clear breakpoint in file $2 at line $3.
#	step-over			Output the command used to step over the current line of execution.
#	step-in				Output the command used to step into the current line of execution.
#	step-out			Output the command used to step to the end of the current frame.
#	where				Output the command used to get details of the current code location.
#	variables			Output the command used to get details of local variables.
#	print				Output the command used to print a description of expression $2.
#	set					Output the command used to set the value of expression $2 to $3.
#	watch				Output the command used to set a watchpoint for variable $2.
#	select-frame		Output the command used to select the current frame. Arguments:
#							$2 = target frame number, $3 = target thread name,
#							$4 = current frame number, $5 = current thread name
#
# Parsing debugger data:
#
#	where-parse		Read from stdin the debugger's output from the "where" command, and
#					parse it to JSON format to be read by CodeRunner's user interface.
#	variables-parse	Read from stdin the debugger's output from the "variables" command, and
#					parse it to JSON format to be read by CodeRunner's user interface.
#
# CodeRunner debugger options:
#
#	options			Output various options affecting CodeRunner's debugger behavior.
#

if [ "$1" == "debugger-server" ]; then
	command="${CR_RUN_COMMAND/java /java -Xdebug -Xrunjdwp:transport=dt_socket,address=$CR_RUNID,server=y,suspend=y }"
	eval "$command" '"${@:2}"'

elif [ "$1" == "debugger-client" ]; then
	jdb -attach $CR_RUNID

elif [ "$1" == "prompt-pattern" ]; then
	echo "(^|(?<=\\n))\\w+\[\d+\] "

elif [ "$1" == "ignore-pattern" ]; then
	echo "^Listening for transport dt_socket at address:"
	
elif [ "$1" == "breakpoint-set" ]; then
	class=`"$CR_DEVELOPER_DIR/bin/parsejava" --line $3 "$2" 2>/dev/null` # Get class name
	if [ $? -ne 0 ]; then
		class=`basename -s .java "$2"`
	fi
	echo "stop at $class:$3"

elif [ "$1" == "breakpoint-clear" ]; then
	class=`"$CR_DEVELOPER_DIR/bin/parsejava" --line $3 "$2" 2>/dev/null` # Get class name
	if [ $? -ne 0 ]; then
		class=`basename -s .java "$2"`
	fi
	echo "clear $class:$3"

elif [ "$1" == "launch" ]; then
	echo "run"

elif [ "$1" == "continue" ]; then
	echo "run"

elif [ "$1" == "pause" ]; then
	echo "interrupt 0x1"

elif [ "$1" == "step-over" ]; then
	echo "next"

elif [ "$1" == "step-in" ]; then
	echo "step"

elif [ "$1" == "step-out" ]; then
	echo "step up"

elif [ "$1" == "where" ]; then
	echo "where all"

elif [ "$1" == "variables" ]; then
	echo "locals"

elif [ "$1" == "variables-parse" ]; then
	debuggerhelper jdb variables

elif [ "$1" == "where-parse" ]; then
	debuggerhelper jdb where "$2"

elif [ "$1" == "print" ]; then
	echo "dump $2"

elif [ "$1" == "set" ]; then
	echo "set $2 = $3"

elif [ "$1" == "select-frame" ]; then
	if [ "$3" != "$5" ]; then
		exit 0
	elif (( $2 > $4 )); then
		echo "up $(( $2 - $4 ))"
	else
		echo "down $(( $4 - $2 ))"
	fi

elif [ "$1" == "message-pattern" ]; then
	echo "^(\s*>\s*)?(Unable to set deferred breakpoint|Exception occurred)"

elif [ "$1" == "options" ]; then
	echo "prompt_indicates_paused=y,disable_tab_completion=y,kill_child_processes=y"

fi
