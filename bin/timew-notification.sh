#!/bin/bash

# Copyright 2020 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : timew-notification.sh
#
# Send a notification about the current timew status
# To be maily used as a cronjob

TAGS=$(timew | grep -E 'Tracking' | sed -E 's/^.*Tracking[[:space:]]+//')
TIME=$(timew | grep -E 'Total' | sed -E 's/^.*Total[[:space:]]+//')
if [ -x "/usr/bin/notify-send" ]
then
    timew > /dev/null 2>&1 && notify-send -t 1000 -u normal -c im -i gnome-pomodoro -a  "Timew" "Timew" "${TIME}\n${TAGS}"
fi
