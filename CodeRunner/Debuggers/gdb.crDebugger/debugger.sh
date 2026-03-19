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
	# Just sleep and let gdb use this tty for program I/O
	tty > "$CR_TMPDIR/db_tty"
	sleep 99999999

elif [ "$1" == "debugger-client" ]; then
	args=""
	for arg in "${@:2}"; do
		args+=\'${arg//\'/\'\\\'\'}\'" "
	done
	echo "$args" > "$CR_TMPDIR/db_args"
	tty=`cat "$CR_TMPDIR/db_tty"`

	gdb -q --tty="$tty" -x "$CR_DEBUGGER_DIR/gdb_init" --args "$compiler"

elif [ "$1" == "prompt-pattern" ]; then
	echo "((\(gdb\) )|((^|\n)\s*>))$"

elif [ "$1" == "message-pattern" ]; then
    echo "(?i)(^Program received signal )|(\b[Ww]atchpoint \d+:)|(^(Old|New) value = )|(program terminated with signal)"

elif [ "$1" == "termination-pattern" ]; then
	echo "(?i)(?:program terminated with signal)"

elif [ "$1" == "ignore-pattern" ]; then
	echo "^warning: GDB: Failed to set controlling terminal:"

elif [ "$1" == "launch" ]; then
	args=`cat "$CR_TMPDIR/db_args"`
	if [ ! -z $CR_INPUT ]; then
		echo "run $args < '$CR_INPUT'"
	else
		echo "run $args"
	fi

elif [ "$1" == "continue" ]; then
	echo "continue"

elif [ "$1" == "breakpoint-set" ]; then
	echo "break \"$2\":$3"

elif [ "$1" == "breakpoint-clear" ]; then
	echo "clear \"$2\":$3"

elif [ "$1" == "step-over" ]; then
	echo "next"

elif [ "$1" == "step-in" ]; then
	echo "step"

elif [ "$1" == "step-out" ]; then
	echo "finish"

elif [ "$1" == "where" ]; then
	echo "cr_where"

elif [ "$1" == "where-parse" ]; then
	php "$CR_DEBUGGER_DIR/gdb_where_parse.php"
	if [ $? -eq 57 ]; then
		# The program is not running for some reason. Exit status 57 causes CodeRunner to terminate the debugger and show the log.
		exit 57
	fi

elif [ "$1" == "variables" ]; then
	echo "cr_vars"

elif [ "$1" == "variables-parse" ]; then
	php "$CR_DEBUGGER_DIR/gdb_variables_parse.php"

elif [ "$1" == "print" ]; then
	echo "p $2"

elif [ "$1" == "set" ]; then
	echo "set var $2 = $3"

elif [ "$1" == "watch" ]; then
	echo "watch $2"

elif [ "$1" == "select-frame" ]; then
	if [ "$3" != "$5" ]; then
		echo "thread $3"
	fi
	echo "frame $2"
elif [ "$1" == "options" ]; then
	echo "prompt_indicates_paused=y,client_is_main_process=y,input_using_environment=y,kill_child_processes=y,ignore_first_n_child_process_statistics=1"

fi
