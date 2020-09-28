#!/bin/bash
# sync offlineimap
# Ref: https://hobo.house/2015/09/09/take-control-of-your-email-with-mutt-offlineimap-notmuch/

# Do not kill existing process by default
# Sometimes it gets hung, so we do need to kill it
KILL_SYNC="no"
NOTIFY="no"
MAILDIR="$HOME/Mail"

check ()
{
    pgrep -fa offlineimap -u asinha
    if [ $? -eq 0 ]
    then
        if [ "$KILL_SYNC" == "no" ]
        then
            echo "Already syncing, letting it run."
            exit 0
        else
            echo "Already syncing, killing as instructed."
            while pkill -f offlineimap -u asinha
            do
                sleep 2;
            done
        fi
    fi
}

quick ()
{
    (offlineimap -u quiet -q -s) &
    echo "Quick sync started"
}

full ()
{
    (offlineimap -u quiet -s) &
    echo "Full sync started"
}

status ()
{
    pgrep -fa offlineimap -u asinha
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

if [ $# -eq 0 ]
then
    echo "You did not tell me what to do. Exiting."
    exit 0
fi

# parse options
while getopts "knqfs" OPTION
do
    case $OPTION in
        k)
            KILL_SYNC="yes"
            ;;
        n)
            NOTIFY="yes"
            ;;
        q)
            check
            quick
            timestamp
            ;;
        f)
            check
            full
            timestamp
            ;;
        s)
            status
            exit 0
            ;;
        ?)
            echo "Nothing to do. Exiting."
            exit 0
            ;;
    esac
done
