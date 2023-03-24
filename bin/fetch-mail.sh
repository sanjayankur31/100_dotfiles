#!/bin/bash
# sync offlineimap
# Ref: https://hobo.house/2015/09/09/take-control-of-your-email-with-mutt-offlineimap-notmuch/

NOTIFY="no"
MAILDIR="$HOME/Mail"
processinfo=""

kill_if_running ()
{
    status
    if [ -n "$processinfo" ]
    then
        echo "Killing offlineimap as instructed."
        while pkill -f offlineimap -u asinha
        do
            sleep 2;
        done
    else
        echo "Offlineimap not running"
    fi
}

quick ()
{
    status
    if [ -z "$processinfo" ]
    then
        (offlineimap -u quiet -q -s) &
        echo "Quick sync started"
    fi
}

full ()
{
    status
    if [ -z "$processinfo" ]
    then
        (offlineimap -u quiet -s) &
        echo "Full sync started"
    fi
}

status ()
{
    processinfo="$(pgrep -fa offlineimap -u asinha)"
    if [ $? -eq 0 ]
    then
        res_pid="${processinfo%% *}"
        echo "Sync is running with pid ${res_pid}, started: $(ps -p $res_pid -o lstart= )"
    else
        echo "Sync is not running"
    fi
}

timestamp ()
{
    echo "$(date +%H%M)" > $MAILDIR/status
    newmails="$(find $MAILDIR -name 'new' -type d -exec ls -l '{}' \;  | sed '/total/ d' | wc -l)"
    echo "New: $newmails" >> $MAILDIR/status

    if [ -x "/usr/bin/notify-send" ] && [ "$NOTIFY" == "yes" ]
    then
        notify-send -t -1 -i evolution -c "email.arrived" -a  "Neomutt " "Neomutt" "$newmails new e-mails"
    fi
}

usage () {
    echo "Usage: $0 [-k] [-n] [-qfs]"
    echo "Sync wrapper around offlineimap"
    echo
    echo "Options:"
    echo "-n: send notification using notify-send"
    echo "-s: check status"
    echo "-q: quick sync"
    echo "-Q: quick sync; kill existing instance"
    echo "-f: full sync"
    echo "-F: full sync; kill existing instance"
    echo "-k: kill existing instance"
}

if [ $# -eq 0 ]
then
    echo "You did not tell me what to do. Exiting."
    exit 0
fi

# parse options
while getopts "knqfQFsh" OPTION
do
    case $OPTION in
        k)
            kill_if_running
            exit 0
            ;;
        n)
            NOTIFY="yes"
            ;;
        q)
            quick
            timestamp
            ;;
        Q)
            kill_if_running
            quick
            timestamp
            ;;
        f)
            full
            timestamp
            ;;
        F)
            kill_if_running
            full
            timestamp
            ;;
        s)
            status
            exit 0
            ;;
        h)
            usage
            exit 0
            ;;
        ?)
            echo "Nothing to do. Exiting."
            usage
            exit 0
            ;;
    esac
done
