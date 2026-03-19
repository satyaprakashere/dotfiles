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
	if php -m 2> /dev/null | grep -i xdebug &> /dev/null; then
		for i in {0..50}; do
			nc -z 127.0.0.1 $CR_RUNID &> /dev/null && break
			sleep 0.1
		done
		command="${CR_RUN_COMMAND/php /php -d xdebug.mode=debug -d xdebug.client_port=$CR_RUNID -d xdebug.start_with_request=yes }"
		eval "$command" '"${@:2}"'
	else
		echo -e "Error: Debugging PHP requires that you have Xdebug installed."
		if command -v pecl &> /dev/null; then
			echo -e "\nTo install, simply run the following command in the terminal:\n\n$ pecl install xdebug\n"
		else
			echo -e "\nTo install Xdebug, make sure that you're running the latest version of PHP. You can do this with homebrew, running the command below in your terminal:\n\n$ brew install php\n\nIf you don't have homebrew installed, you can get it at https://brew.sh\nOnce your PHP is up-to-date, install Xdebug using the command:\n\n$ pecl install xdebug\n"
		fi
		echo -e "For more information about Xdebug or help with installation, please visit https://xdebug.org/"
		exit 1
	fi

elif [ "$1" == "debugger-client" ]; then
	dbgpclient 127.0.0.1 $CR_RUNID "(xdebug) "

elif [ "$1" == "prompt-pattern" ]; then
	echo "\(xdebug\) "
	
elif [ "$1" == "breakpoint-set" ]; then
	echo "breakpoint_set -i $((100000+$RANDOM)) -t line -f \"$(php -r 'echo "file://".str_replace("%2F", "/", rawurlencode($argv[1]));' "$2")\" -n $3"

elif [ "$1" == "breakpoint-list" ]; then
	echo "breakpoint_list -i $((100000+$RANDOM))"

elif [ "$1" == "breakpoint-clear" ]; then
	echo "breakpoint_remove -i $((100000+$RANDOM)) -d $(dbgpclient --breakpoint-id "$2" "$3" "$4")"

elif [ "$1" == "launch" ]; then
	echo "run -i $((100000+$RANDOM))"

elif [ "$1" == "continue" ]; then
	echo "run -i $((100000+$RANDOM))"

elif [ "$1" == "pause" ]; then
	:

elif [ "$1" == "step-over" ]; then
	echo "step_over -i $((100000+$RANDOM))"

elif [ "$1" == "step-in" ]; then
	echo "step_into -i $((100000+$RANDOM))"

elif [ "$1" == "step-out" ]; then
	echo "step_out -i $((100000+$RANDOM))"

elif [ "$1" == "where" ]; then
	echo "stack_get -i $((100000+$RANDOM))"

elif [ "$1" == "where-parse" ]; then
	php "$CR_DEBUGGER_DIR/xdebug_where_parse.php"

elif [ "$1" == "variables" ]; then
	echo "context_get -i $((100000+$RANDOM))"

elif [ "$1" == "variables-parse" ]; then
	php "$CR_DEBUGGER_DIR/xdebug_variables_parse.php"

elif [ "$1" == "print" ]; then
	echo "eval print_r($(php -r '$d=json_decode($argv[1], true);echo $d[count($d)-1]["fullname"];' -- "$4"), true)"

elif [ "$1" == "set" ]; then
	echo "eval $2 = $3"

elif [ "$1" == "select-frame" ]; then
	echo "select_frame $2"

elif [ "$1" == "message-pattern" ]; then
	:

elif [ "$1" == "termination-pattern" ]; then
	:
	
elif [ "$1" == "options" ]; then
	echo "prompt_indicates_paused=y,disable_user_pause=y"

fi
