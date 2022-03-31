#!/bin/bash

# Copyright 2021 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : neomutt-compose-wrapper.sh
#
# Wrapper around neomutt to let me pick a mailbox when clicking on neomutt
# links

MAILBOX="no"
NEOMUTT_CONFDIR="~/Sync/99_private/neomuttdir/"
echo "Mailbox to use?"
echo "1: gmail"
echo "2: ucl"
echo "3: hotmail"
echo "4: yahoo"
echo "5: herts"
echo "6: herts-student"
echo -n "> "
read MAILBOX_ID

case $MAILBOX_ID in
    1)
        MAILBOX="gmail"
        ;;
    2)
        MAILBOX="ucl"
        ;;
    3)
        MAILBOX="hotmail"
        ;;
    4)
        MAILBOX="yahoo"
        ;;
    5)
        MAILBOX="herts"
        ;;
    6)
        MAILBOX="herts-student"
        ;;
    *)
        echo "Invalid option selected."
        ;;
esac
if [ "no" != "$MAILBOX" ]
then
    # Change mailbox before composing
    echo "source $NEOMUTT_CONFDIR/$MAILBOX.neomuttrc"
    neomutt -e "source $NEOMUTT_CONFDIR/$MAILBOX.neomuttrc" "$@"
else
    sleep 1s
fi
