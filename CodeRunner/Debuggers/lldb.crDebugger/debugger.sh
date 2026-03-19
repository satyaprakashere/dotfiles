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
	# Just sleep and let lldb use this tty for program I/O
	tty > "$CR_TMPDIR/db_tty"
	sleep 99999999

elif [ "$1" == "debugger-client" ]; then
	args=""
	for arg in "${@:2}"; do
		args+=\'${arg//\'/\'\\\'\'}\'" "
	done
	echo "$args" > "$CR_TMPDIR/db_args"

	lldb -s "$CR_DEBUGGER_DIR/lldb_init" -f "$compiler"

elif [ "$1" == "prompt-pattern" ]; then
	echo "(\(lldb\) (?= *$)|((?<=^|\n)\s*\d*> ?)(?= *$))"
	
elif [ "$1" == "breakpoint-set" ]; then
	echo "breakpoint set -f '$(basename "$2")' -l $3" -o ${4:-0}

elif [ "$1" == "breakpoint-clear" ]; then
	echo "breakpoint clear -f '$(basename "$2")' -l $3"

elif [ "$1" == "launch" ]; then
	args=`cat "$CR_TMPDIR/db_args"`
	tty=`cat "$CR_TMPDIR/db_tty"`
	if [ ! -z $CR_INPUT ]; then
		echo "process launch -i '$CR_INPUT' -o '$tty' -e '$CR_DEBUGGER_CLIENT_STDERR' -- $args"
	else
		echo "process launch -i '$tty' -o '$tty' -e '$CR_DEBUGGER_CLIENT_STDERR' -- $args"
	fi

elif [ "$1" == "continue" ]; then
	echo "continue"

elif [ "$1" == "pause" ]; then
	echo "process interrupt"

elif [ "$1" == "step-over" ]; then
	echo "next"

elif [ "$1" == "step-in" ]; then
	echo "step"

elif [ "$1" == "step-out" ]; then
	echo "finish"

elif [ "$1" == "where" ]; then
	echo "bt all"

elif [ "$1" == "variables" ]; then
	if [ $CR_DEBUGGER_VARIABLES_SHOW_ALL -eq 1 ] || [[ "$CR_FILENAME" =~ \.swift$ ]]; then
		g="-g"
	fi
	depth=$((${2:-2}+1))
	echo "frame variable -s -P $depth --depth $depth -T $g"

elif [ "$1" == "variables-parse" ]; then
	if [ -f "$CR_TMPDIR/lldb_returnvalue_$CR_RUNID" ]; then
		(cat "$CR_TMPDIR/lldb_returnvalue_$CR_RUNID"; cat) | lldbhelper --variables
	else
		lldbhelper --variables
	fi

elif [ "$1" == "where-parse" ]; then
	data="$(cat)"
	returnValue="$(echo "$data" | grep -i "return value:")"
	if [ -z "$returnValue" ]; then
		[ -f "$CR_TMPDIR/lldb_returnvalue_$CR_RUNID" ] && rm "$CR_TMPDIR/lldb_returnvalue_$CR_RUNID" &> /dev/null
	else
		echo "$returnValue" > "$CR_TMPDIR/lldb_returnvalue_$CR_RUNID" 2> /dev/null
	fi
	echo "$data" | lldbhelper --stack

elif [ "$1" == "print" ]; then
	if [ ! -z "$4" ]; then
		p="$(echo "$4" | lldbhelper --print-var 2>/dev/null)"
		if [ ! -z "$p" ]; then
			echo "po $p"
			exit
		fi
	fi
	expr="$2"
	if [ "${expr#*\[\"}" == "$expr" ]; then
		echo "po $expr"
	fi

elif [ "$1" == "set" ]; then
	echo "expr $2 = $3"

elif [ "$1" == "watch" ]; then
	echo "watchpoint set variable $2"

elif [ "$1" == "select-frame" ]; then
	if [ "$3" != "$5" ]; then
		echo "thread select $3"
	fi
	echo "frame select $2"

elif [ "$1" == "message-pattern" ]; then
	echo "((?i)(Program received signal )|(Watchpoint .* hit\b)|((old|new) value\b)|(unable to attach))"

elif [ "$1" == "termination-pattern" ]; then
	echo "[Pp]rocess (?:\d+ )?exited with status (?:= )?-?(\d+)"

elif [ "$1" == "options" ]; then
	echo "client_is_main_process=y,input_using_environment=y,kill_child_processes=y,ignore_first_n_child_process_statistics=2,disable_tab_completion=y"
fi
