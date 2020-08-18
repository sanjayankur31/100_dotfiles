#!/bin/bash
# https://hobo.house/2015/09/09/take-control-of-your-email-with-mutt-offlineimap-notmuch/
# sync offlineimap if you have connection to the internet
# and you can ping your imap server successfully.

# Not the best script, but it works.
# Only checks the first remote if there are multiple to see if an internet
# connection is active.
# A better script would be one that checks each remote individually and asks
# offlineimap to work on that only, using the -a option

check ()
{
    pgrep -fa offlineimap -u asinha
    if [ $? -eq 0 ]
    then
        echo "Already syncing, letting it run."
        exit 0
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
    echo "$(date +%H%M)" > ~/Mail/status
}

if [ $# -eq 0 ]
then
    echo "You did not tell me what to do. Exiting."
    exit 0
fi

# parse options
while getopts "qfs" OPTION
do
    case $OPTION in
        q)
            check
            quick
            timestamp
            exit 0
            ;;
        f)
            check
            full
            timestamp
            exit 0
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
