#!/bin/bash
# -*- shell-scripts -*-

FRAMECOUNT=$(emacsclient -e "(current-frame-configuration)" 2> /dev/null | grep '(#<frame' | wc -l )
FRAME=

if [ $FRAMECOUNT -eq 1 ]; then
    FRAME=-c
elif [ $FRAMECOUNT -eq 0 ]; then
    # start an emacs with guaranteed daemon
    XLIB_SKIP_ARGB_VISUALS=1 emacs --daemon 
fi


if [ -z "$*" ]; then
    XLIB_SKIP_ARGB_VISUALS=1 emacsclient $FRAME "*scratch*"
else
    XLIB_SKIP_ARGB_VISUALS=1 emacsclient $FRAME "$*"
fi
