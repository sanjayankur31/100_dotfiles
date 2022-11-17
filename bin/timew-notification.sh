#!/bin/bash

# Copyright 2020 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : timew-notification.sh
#
#
# Print one liner timew summary
# Can also send a notification about the current timew status


notification ()
{
    if [ -x "/usr/bin/notify-send" ]
    then
        timew > /dev/null 2>&1 && notify-send -t 1000 -u normal -c im -i gnome-pomodoro -a  "Timew" "Timew" "${TIME}\n${TAGS}"
    fi
}

TAGS=$(timew | grep -E 'Tracking' | sed -E 's/^.*Tracking[[:space:]]+//')
TIME=$(timew | grep -E 'Total' | sed -E 's/^.*Total[[:space:]]+//')
# Only print the first five letters of tag string: the idea is just to remind one of what the current task is
echo "TW: ${TIME} ${TAGS:0:5}..."

while getopts "n" OPTION
do
    case $OPTION in
        n)
            notification
            exit 0
            ;;
    esac
done
