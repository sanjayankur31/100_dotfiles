#!/bin/bash

resume ()
{
    timew || timew continue
}

pause ()
{
    timew && timew stop
}

clean ()
{
    for entry in $(timew summary :ids | grep -o '@.*' | sed -E 's/(^@[[:digit:]]+[[:space:]]+)/\1 |/' | sed -E 's/([[:digit:]]+:[[:digit:]]+:[[:digit:]]+ )/| \1/' | sed 's/|.*|//' | sed -E 's/[[:space:]]{2,}/ /' | cut -d ' ' -f 1,4 | grep -E '0:0[01]:..' | cut -d ' ' -f 1 | tr '\n' ' '); do timew delete "$entry"; done
}

usage ()
{
    echo "$0: wrapper script around timewarrior to carry out common tasks"
    echo "For use with Gnome-Pomodoro's action plugin"
    echo
    echo "Usage: $0 <option>"
    echo
    echo "OPTIONS:"
    echo "-r    resume tracking of most recently tracked task"
    echo "-p    pause tracking"
    echo "-c    clean up short tasks (less than 2 minutes long)"
}

# check for options
if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi

# parse options
while getopts "rpch" OPTION
do
    case $OPTION in
        r)
            resume
            exit 0
            ;;
        p)
            pause
            exit 0
            ;;
        c)
            clean
            exit 0
            ;;
        h)
            usage
            exit 1
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done
