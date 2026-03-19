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
	filename="$CR_DEBUGGER_DIR/pdb_server.py"
	eval "$CR_RUN_COMMAND" '"${@:2}"'

elif [ "$1" == "debugger-client" ]; then
	while true; do
		nc 127.0.0.1 $CR_RUNID
		if [ $? -eq 0 ]; then
			break
		fi
		sleep 0.1
	done
	sleep 0.5

elif [ "$1" == "prompt-pattern" ]; then
	echo "(?i)(^|(?<=\\n))\(Pdb\) "
	
elif [ "$1" == "breakpoint-set" ]; then
	echo "break $2:$3"

elif [ "$1" == "breakpoint-clear" ]; then
	echo "clear $2:$3"

elif [ "$1" == "launch" ]; then
	echo "cont"

elif [ "$1" == "continue" ]; then
	echo "cont"

elif [ "$1" == "step-over" ]; then
	echo "next"

elif [ "$1" == "step-in" ]; then
	echo "step"

elif [ "$1" == "step-out" ]; then
	echo "up"

elif [ "$1" == "where" ]; then
	echo "where"

elif [ "$1" == "where-parse" ]; then
	python3 "$CR_DEBUGGER_DIR/pdb_where_parse.py"

elif [ "$1" == "variables" ]; then
	echo "exec(\"global __cr_debugger_variables_show_all\n__cr_debugger_variables_show_all = ${CR_DEBUGGER_VARIABLES_SHOW_ALL:-0}\n__cr_debugger_variables_depth = ${2:-3}\n\"+open('$CR_DEBUGGER_DIR/pdb_get_variables.py').read())"

elif [ "$1" == "variables-parse" ]; then
	:

elif [ "$1" == "print" ]; then
	if [ ! -z "$4" ]; then
		echo "print($(python3 "$CR_DEBUGGER_DIR/pdb_print.py" 2>/dev/null <<< "$4"))"
	else
		echo "print($2)"
	fi

elif [ "$1" == "set" ]; then
	if [ ! -z "$5" ]; then
		echo "!$(python3 "$CR_DEBUGGER_DIR/pdb_print.py" 2>/dev/null <<< "$5") = $3"
	else
		echo "!$2 = $3"
	fi

elif [ "$1" == "select-frame" ]; then
	if (( $2 > $4 )); then
		cmd="up"
		num=$(($2 - $4))
	else
		cmd="down"
		num=$(($4 - $2))
	fi
	for x in `seq 1 $num`; do
		echo "$cmd"
	done

elif [ "$1" == "message-pattern" ]; then
	echo "^[*]{3} Blank or comment"

elif [ "$1" == "continue-pattern" ]; then
	# Ignore these breaks and automatically continue
	echo "_set_stopinfo\(|remote_pdb\.py\(102\)set_trace\("

elif [ "$1" == "options" ]; then
	echo "prompt_indicates_paused=y,setup_at_first_line=y,disable_tab_completion=y,pause_for_commands=y"

fi
