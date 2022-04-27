#!/bin/bash

# Copyright 2021 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : neomutt-compose-wrapper.sh
#
# Wrapper around neomutt to let me pick a mailbox when clicking on neomutt
# links

MAILBOX="no"
NEOMUTT_CONFDIR="~/Sync/99_private/neomuttdir/"
while [ "no" == "$MAILBOX" ]; do
    echo "Mailbox to use?"
    echo "1: gmail"
    echo "2: ucl"
    echo "3: hotmail"
    echo "4: yahoo"
    echo "q: quit"
    echo -n "> "
    read MAILBOX_ID

    case $MAILBOX_ID in
        1)
            MAILBOX="gmail"
            break
            ;;
        2)
            MAILBOX="ucl"
            break
            ;;
        3)
            MAILBOX="hotmail"
            break
            ;;
        4)
            MAILBOX="yahoo"
            break
            ;;
        q)
            exit 0
            ;;
        *)
            echo "Invalid option selected."
            echo
            ;;
    esac
done

# Change mailbox before composing
echo "source $NEOMUTT_CONFDIR/$MAILBOX.neomuttrc"
neomutt -e "source $NEOMUTT_CONFDIR/$MAILBOX.neomuttrc" "$@"
