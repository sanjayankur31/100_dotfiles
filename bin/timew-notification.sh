#!/bin/bash

# Copyright 2020 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File : timew-notification.sh
#
#
# Print one liner timew summary
# Can also send a notification about the current timew status

TAGS=$(timew | grep -E 'Tracking' | sed -E 's/^.*Tracking[[:space:]]+//')
TIME=$(timew | grep -E 'Total' | sed -E 's/^.*Total[[:space:]]+//')

NOTIF_ID_FILE="${XDG_RUNTIME_DIR:-/tmp}/timew-notification-id"

notification ()
{
    if [ -x "/usr/bin/notify-send" ]
    then
        REPLACE_ID=""
        [ -f "$NOTIF_ID_FILE" ] && REPLACE_ID="--replace-id=$(cat "$NOTIF_ID_FILE")"
        timew > /dev/null 2>&1 && \
            notify-send --print-id --expire-time=1000 --urgency=low --transient \
                --category=im --app-icon=io.github.focustimerhq.FocusTimer \
                --app-name="Timew" "Timew" "${TIME}\n${TAGS}" $REPLACE_ID \
            > "$NOTIF_ID_FILE"
    fi
}

byobu_notify ()
{
    # Only print the first five letters of tag string: the idea is just to remind one of what the current task is
    # https://askubuntu.com/questions/184495/why-byobu-custom-status-notification-code-fail-to-show-in-color

    if [ "" != "$TIME" ]
    then
        echo "#[fg=white,bg=green]${TIME} ${TAGS:0:5}...#[default]"
    fi
}

while getopts "n" OPTION
do
    case $OPTION in
        n)
            notification
            exit 0
            ;;
        *)
            echo "No option: what are you looking for?"
            exit 1
    esac
done

# if not -n, byobu notification
byobu_notify
