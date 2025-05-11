#!/bin/bash

# Copyright 2025 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : qute-history-clear.sh
#
# Script to delete history from qutebrowser, since the UI doesn't have an option
#


QUTEDIR="$HOME/.local/share/qutebrowser"
QUTEFILE="history.sqlite"
DRY_RUN="NO"

clear_history () {
    pushd "$QUTEDIR"
        SQL_FILE="$(mktemp)"
        for VAR in "$@"
        do
            echo ">>> Got: ${VAR}"
            echo "delete from History where url like '%${VAR}%';" >> $SQL_FILE
            echo "delete from CompletionHistory where url like '%${VAR}%';" >> $SQL_FILE
            echo "select * from History where url like '%${VAR}%';" >> $SQL_FILE
            echo "select * from CompletionHistory where url like '%${VAR}%';" >> $SQL_FILE
        done
        echo ".quit" >> $SQL_FILE

        echo ">>> Script file is: $SQL_FILE"
        echo ">>> Contents:"
        cat $SQL_FILE

        if [ "NO" == "$DRY_RUN" ]
        then
            echo ">>> Running command"
            cp "$QUTEFILE"  "$QUTEFILE.backup"
            sqlite3 history.sqlite < "$SQL_FILE"
            echo ">>> Command run"
        else
            echo ">>> Dry run. No op"
        fi

        echo ">>> DELETING script file"
        rm -fv "$SQL_FILE"

    popd
}
clear_history_since () {
    set -e
    TIME_SINCE=$(date +"%s" -d "$TIME_STRING")
    set +e

    pushd "$QUTEDIR"
        SQL_FILE="$(mktemp)"
        echo ">>> Got: ${TIME_STRING}: ${TIME_SINCE}"
        echo "delete from History where atime <= ${TIME_SINCE};" >> $SQL_FILE
        echo "delete from CompletionHistory where last_atime <= ${TIME_SINCE};" >> $SQL_FILE
        echo ".quit" >> $SQL_FILE

        echo ">>> Script file is: $SQL_FILE"
        echo ">>> Contents:"
        cat $SQL_FILE

        if [ "NO" == "$DRY_RUN" ]
        then
            echo ">>> Running command"
            cp "$QUTEFILE"  "$QUTEFILE.backup"
            sqlite3 history.sqlite < "$SQL_FILE"
            echo ">>> Command run"
        else
            echo ">>> Dry run. No op"
        fi

        echo ">>> DELETING script file"
        rm -fv "$SQL_FILE"

    popd
}

usage () {
    echo
    echo "$(basename $0): [-dh] <words>"
    echo
    echo "Delete entries from qutebrowser's history"
    echo "Note that this does not remove session data"
    echo
    echo "Usage:"
    echo
    echo "-h: print help and exit"
    echo "-d: dry run"
    echo "    do not run the sql command"
    echo "-t: date command time string"
    echo "    delete history before specified date"

}


# check for options
if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi


check_qute () {
    if pgrep -fa qutebrowser
    then
        echo "Qutebrowser is running. Please exit before running this script"
        exit 1
    fi

}
while getopts "hdt:" OPTION
do
    case $OPTION in
        d)
            DRY_RUN="YES"
            ;;
        t)
            TIME_STRING="$OPTARG"
            check_qute
            clear_history_since
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

shift $(($OPTIND - 1))
check_qute
clear_history "$@"
