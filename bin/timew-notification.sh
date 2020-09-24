#!/bin/bash

# Copyright 2020 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : timew-notification.sh
#
# Send a notification about the current timew status
# To be maily used as a cronjob

if [ -x "/usr/bin/notify-send" ]
then
    notify-send -u low -t 2000 -i gnome-pomodoro -c "presence" -a  "Timew" "Timew" "$(timew)"
fi
