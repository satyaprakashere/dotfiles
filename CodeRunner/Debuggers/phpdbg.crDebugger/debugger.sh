#!/bin/bash

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
	xdebug_message () {
		echo -e "Error: phpdbg is no longer supported for debugging PHP in CodeRunner, but you can use Xdebug instead.\n\nTo switch to Xdebug, go to CodeRunner Preferences -> Languages -> PHP -> Debugger, and select \"xdebug\"."
		exit 1
	}
	phpdbg_version="$(phpdbg --version)"
	if [ -z "$phpdbg_version" ] || [[ "$(echo "$phpdbg_version" | grep -oE 'phpdbg \d+' | grep -oE '\d+')" -gt 7 ]]; then
		xdebug_message
	fi
	
	tty_file="$CR_TMPDIR/db_tty"
	rm "$tty_file" &>/dev/null
	[ ! -z "$CR_INPUT" ] && echo -e "CodeRunner Warning: Program input set in \"Run Settings\" is not supported when debugging PHP code, and will be ignored. Manually access input data using file_get_contents(getenv(\"CR_INPUT\"))\n"
	fifo="$CR_TMPDIR/db_fifo_$CR_RUNID"
	mkfifo "$fifo" &>/dev/null
	trap "rm \"$fifo\" &>/dev/null" EXIT SIGHUP
	this_tty=$(tty)
	while [ ! -f "$tty_file" ]; do
		sleep 0.2
	done
	tty=$(cat "$tty_file")
	cat "$tty" > "$fifo" &
	cat > "$fifo" &
	
	if command -v phpdbg &> /dev/null; then
		phpdbg -qbx "-i$CR_DEBUGGER_DIR/phpdbg_init" "-c/etc/php.ini" -e "$CR_FILENAME" "${@:2}" < "$fifo" | php "$CR_DEBUGGER_DIR/phpdbg_parse.php" "$this_tty" > "$tty"
	else
		xdebug_message
	fi

elif [ "$1" == "debugger-client" ]; then
	tty > "$CR_TMPDIR/db_tty_tmp"
	while [ -f "$CR_TMPDIR/db_tty" ]; do
		sleep 0.2
	done
	mv "$CR_TMPDIR/db_tty_tmp" "$CR_TMPDIR/db_tty" &>/dev/null
	sleep 99999999

elif [ "$1" == "prompt-pattern" ]; then
	echo "(^|(?<=\\n))phpdbg> "
	
elif [ "$1" == "breakpoint-set" ]; then
	if [ "$PWD/$CR_FILENAME" -ef "$2" ]; then
		echo "break $3"
	elif [[ ! $2 = *' '* ]]; then
		echo "break $2:$3"
	fi

elif [ "$1" == "breakpoint-clear" ]; then
	echo "break del $4"

elif [ "$1" == "launch" ]; then
	echo "run"

elif [ "$1" == "continue" ]; then
	echo "continue"

elif [ "$1" == "step-over" ]; then
	echo "step"

elif [ "$1" == "step-in" ]; then
	echo "step"

elif [ "$1" == "step-out" ]; then
	echo "leave"

elif [ "$1" == "where" ]; then
	echo "ev eval('include(\'$CR_DEBUGGER_DIR/phpdbg_backtrace.php\'); return \$__cr_backtrace;')"

elif [ "$1" == "where-parse" ]; then
	:

elif [ "$1" == "variables" ]; then
	echo "ev eval('global \$__cr_variables_show_all, \$__cr_variables_depth; \$__cr_variables_show_all = $CR_DEBUGGER_VARIABLES_SHOW_ALL; \$__cr_variables_depth = ${2:-3}; include(\'$CR_DEBUGGER_DIR/phpdbg_variables.php\'); return \$__cr_variables;')"

elif [ "$1" == "variables-parse" ]; then
	:

elif [ "$1" == "print" ]; then
	echo "ev $2"

elif [ "$1" == "set" ]; then
	echo "ev $2 = $3"

elif [ "$1" == "select-frame" ]; then
	:

elif [ "$1" == "message-pattern" ]; then
	:

elif [ "$1" == "termination-pattern" ]; then
	echo "\[phpdbg server exited \((\d+)\)\]"
	
elif [ "$1" == "breakpoint-id-pattern" ]; then
	echo "\[Breakpoint #(\d+)"

elif [ "$1" == "options" ]; then
	echo "prompt_indicates_paused=y,disable_tab_completion=y,input_using_environment=y"

fi
