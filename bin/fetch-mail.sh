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
    while pkill offlineimap -u asinha
    do
        sleep 2
    done
}

quick ()
{
    offlineimap -u quiet -q -s -c ~/Sync/99_private/mail/offlineimaprc
}

full ()
{
    offlineimap -u quiet -s -c ~/Sync/99_private/mail/offlineimaprc
}

# parse options
while getopts "qf" OPTION
do
    case $OPTION in
        q)
            check
            quick
            exit 0
            ;;
        f)
            check
            full
            exit 0
            ;;
        ?)
            echo "Nothing to do."
            exit 1
            ;;
    esac
done
