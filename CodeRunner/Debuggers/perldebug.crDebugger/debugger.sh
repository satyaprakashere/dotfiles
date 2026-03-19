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
	rm "$CR_TMPDIR/db_tty" &>/dev/null
	while [ ! -f "$CR_TMPDIR/db_tty" ]; do
		sleep 0.2
	done
	tty=`cat "$CR_TMPDIR/db_tty"`
	export PERLDB_OPTS="TTY=$tty inhibit_exit=0"

	command="${CR_RUN_COMMAND/perl /perl -d }"
	eval "$command" '"${@:2}"'

elif [ "$1" == "debugger-client" ]; then
	tty > "$CR_TMPDIR/db_tty_tmp"
	while [ -f "$CR_TMPDIR/db_tty" ]; do
		sleep 0.2
	done
	mv "$CR_TMPDIR/db_tty_tmp" "$CR_TMPDIR/db_tty" &>/dev/null
	sleep 99999999

elif [ "$1" == "prompt-pattern" ]; then
	echo "(^|\n)\s*DB<+\d+>+\s*$"

elif [ "$1" == "launch" ]; then
	echo "c"

elif [ "$1" == "continue" ]; then
	echo "c"

elif [ "$1" == "breakpoint-set" ]; then
	if [ "$PWD/$CR_FILENAME" -ef "$2" ]; then
		echo "b $3"
	fi

elif [ "$1" == "breakpoint-clear" ]; then
	if [ "$PWD/$CR_FILENAME" -ef "$2" ]; then
		echo "B $3"
	fi

elif [ "$1" == "step-over" ]; then
	echo "n"

elif [ "$1" == "step-in" ]; then
	echo "s"

elif [ "$1" == "step-out" ]; then
	echo "r"

elif [ "$1" == "where" ]; then
	echo "source $CR_DEBUGGER_DIR/perl_stacktrace"

elif [ "$1" == "where-parse" ]; then
	debuggerhelper perldebug where

elif [ "$1" == "variables" ]; then
	echo "y"

elif [ "$1" == "variables-parse" ]; then
	debuggerhelper perldebug variables

elif [ "$1" == "print" ]; then
	echo "p $2"

elif [ "$1" == "set" ]; then
	echo "$2 = $3"

elif [ "$1" == "watch" ]; then
	echo "w $2"

elif [ "$1" == "message-pattern" ]; then
	echo "^Line \d+ not breakable."

elif [ "$1" == "options" ]; then
	echo "prompt_indicates_paused=y,setup_at_first_line=y"

fi
