#!/bin/bash
# sync offlineimap
# Ref: https://hobo.house/2015/09/09/take-control-of-your-email-with-mutt-offlineimap-notmuch/

VERSION="1.0"
NOTIFY="no"
MAILDIR="$HOME/Mail"
processinfo=""
FULL="no"
QUICK="no"
KILL="no"
TIMESTAMP="no"
NEWMAILS=0
OLDMAILS=0
INCMAILS=0

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

archive_stats () {
    cp $MAILDIR/status $MAILDIR/status.old || true
}

timestamp ()
{
    # wait for process to finish if it is running
    while pgrep -fa offlineimap -u asinha 2>&1 > /dev/null
    do
        sleep 2
    done

    echo "$(date +%H%M)" > $MAILDIR/status
    NEWMAILS="$(find $MAILDIR -path "*/new/*" -type f  | wc -l)"
    echo "$NEWMAILS" >> $MAILDIR/status
}

calculate_new ()
{
    NEWMAILS="$(tail -n 1 $MAILDIR/status)"
    OLDMAILS="0"

    if [ -f "$MAILDIR/status.old" ]
    then
        OLDMAILS="$(tail -n 1 $MAILDIR/status.old)"
    fi

    INCMAILS="$((NEWMAILS - OLDMAILS))"

    if [ 0 -ge $INCMAILS ]
    then
        INCMAILS=0
    fi
}

notify_echo ()
{
    calculate_new
    echo "neomutt: $NEWMAILS ($INCMAILS) new e-mails"
}

notify_tmux ()
{
    calculate_new
    echo "#[fg=white,bg=blue]${NEWMAILS} ($INCMAILS)#[default]"
}
notify ()
{
    calculate_new
    if [ -x "/usr/bin/notify-send" ]
    then
        notify-send -t -1 -i evolution -c "email.arrived" -a  "Neomutt " "Neomutt" "$NEWMAILS ($INCMAILS) new e-mails"
    fi
}

usage () {
    echo "Usage: $0 [-knqfQFsth]"
    echo "Sync wrapper around offlineimap (v$VERSION)"
    echo
    echo "Options:"
    echo "-k: kill existing instance"
    echo "-n: send notification using notify-send"
    echo "-N: echo notification for use in tmux"
    echo "-q: quick sync"
    echo "-f: full sync"
    echo "-Q: quick sync; kill existing instance"
    echo "-F: full sync; kill existing instance"
    echo "-s: check status"
    echo "-t: update status file"
    echo "-h: print help and exit"
}

# parse options
while getopts "knqfQFsth" OPTION
do
    case $OPTION in
        k)
            KILL="yes"
            ;;
        n)
            NOTIFY="yes"
            ;;
        N)
            NOTIFY="tmux"
            ;;
        t)
            ARCHIVE="yes"
            TIMESTAMP="yes"
            ;;
        q)
            ARCHIVE="yes"
            STATUS="yes"
            QUICK="yes"
            TIMESTAMP="yes"
            ;;
        Q)
            ARCHIVE="yes"
            STATUS="yes"
            KILL="yes"
            QUICK="yes"
            TIMESTAMP="yes"
            ;;
        f)
            ARCHIVE="yes"
            STATUS="yes"
            FULL="yes"
            TIMESTAMP="yes"
            ;;
        F)
            ARCHIVE="yes"
            STATUS="yes"
            KILL="yes"
            FULL="yes"
            TIMESTAMP="yes"
            ;;
        s)
            STATUS="yes"
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


if [ "yes" == "$ARCHIVE" ]
then
    archive_stats
fi

if [ "yes" == "$KILL" ]
then
    kill_if_running
fi

if [ "yes" == "$QUICK" ]
then
    quick
elif [ "yes" == "$FULL" ]
then
    full
fi

if [ "yes" == "$TIMESTAMP" ]
then
    timestamp
fi

if [ "yes" == "$STATUS" ]
then
    status
fi

if [ "yes" == "$NOTIFY" ]
then
    notify
elif [ "tmux" == "$NOTIFY" ]
then
    notify_tmux
else
    notify_echo
fi

exit 0
