#!/bin/bash

# Copyright 2021 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File :  bin/qute-block-hosts.sh
# Toggle blocking my list for qutebrowser

enable_block () {
    pushd ~/.config/qutebrowser
        if [ -f "blocked-hosts" ]
        then
            echo "OK: host blocking already enabled"
            exit 0
        fi

        if [ -f "blocked-hosts.txt" ]
        then
            cp blocked-hosts.txt blocked-hosts && echo "OK: host blocking enabled"
        else
            echo "ERROR: blocked-hosts.txt not found."
            exit -1
        fi
    popd
}
disable_block () {
    pushd ~/.config/qutebrowser
        if [ -f "blocked-hosts" ]
        then
            rm -f blocked-hosts && echo "OK: host blocking disabled"
        else
            echo "OK: host blocking already disabled"
            exit 0
        fi
    popd
}

toggle_block () {
    pushd ~/.config/qutebrowser
        if [ -f "blocked-hosts" ]
        then
            disable_block
        else
            enable_block
        fi
    popd
    exit 0
}

function usage() {
    echo "$0: Update user host blocking list"
    echo
    echo "Usage: $0 [-edth]"
    echo
    echo "-e: enable host blocking list"
    echo "-d: disable host blocking list"
    echo "-t: toggle host blocking"
    echo "-h: print this usage text and exit"
}

if [ $# -lt 1 ]
then
    usage
    exit 1
fi

# parse options
while getopts "edth" OPTION
do
    case $OPTION in
        e)
            enable_block
            exit 0
            ;;
        d)
            disable_block
            exit 0
            ;;
        t)
            toggle_block
            exit 0
            ;;
        h)
            usage
            exit 0
            ;;
    esac
done
