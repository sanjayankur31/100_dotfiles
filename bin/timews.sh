#!/bin/bash

tags=("job" "email" "research" "reading")

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

report ()
{
    echo "*** Complete report ***"
    timew summary "$1"

    echo "*** Report by tag ***"
    for atag in "${tags[@]}"
    do
        echo "*** $atag ***"
        timew summary "$atag" "$1"
    done

}

totals_report ()
{
    regex=""
    for atag in "${tags[@]}"
    do
        regex="${regex:+$regex|}${atag} "
    done
    # echo "Regex is '^(${regex})'"

    echo "*** Totals (${tags[@]}) ***"
    timew report totals "$1" | grep -E "^($regex)"

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
    echo "-d    print report for tags for current day"
    echo "-w    print report for tags for this week"
    echo "-l    print report for tags for last week"
    echo "-m    print report for tags for month"
    echo "-D    print totals report for tags for current day"
    echo "-W    print totals report for tags for this week"
    echo "-L    print totals report for tags for last week"
    echo "-M    print totals report for tags for month"
}

# check for options
if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi

# parse options
while getopts "rpcdDwWlLmMh" OPTION
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
        d)
            report ":day"
            exit 0
            ;;
        w)
            report ":week"
            exit 0
            ;;
        l)
            report ":lastweek"
            exit 0
            ;;
        m)
            report ":month"
            exit 0
            ;;
        D)
            totals_report ":day"
            exit 0
            ;;
        W)
            totals_report ":week"
            exit 0
            ;;
        L)
            totals_report ":lastweek"
            exit 0
            ;;
        M)
            totals_report ":month"
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
