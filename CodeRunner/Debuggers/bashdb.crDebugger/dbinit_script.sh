[ ! -z "$CR_DEBUGGER_DIR" ] && export CR_VARIABLES_TMP="$(declare | debuggerhelper bashdb variables parse)"
[ ! -z "$CR_INPUT" ] && exec < "$CR_INPUT"
