#!/usr/bin/bash
# add a email from mutt to taskwarrior
sender=""
subject=""
# default project
start_task=""

get_info (){
    while IFS= read -r line
    do
        if [ -z "$sender" ]
        then
            # sender="$(echo "$line" | sed -n '/^From:/ p;q')"
            sender="$(echo "$line" | grep "^From:" | awk -F: '{print $2}' | sed -e 's/^[[:space:]]*//')"
        fi
        if [ -z "$subject" ]
        then
            subject="$(echo "$line" | grep "^Subject:" | sed -e  's/Subject://' -e 's/^[[:space:]]*//')"
            # subject="$(echo "$line" | sed -n '/^Subject:/ p;q')"
        fi
    done
}

process_task () {
    # there must be a sender, the subject may be empty
    if [ -n "$sender" ]
    then
        echo "$sender: $subject"
        # Add the task
        # echo "Arguments: $*"
        task add "$@" && task +LATEST annotate "$sender: $subject"
        # Start task if needed
        if [ "$start_task" = "yes" ]; then
            task +LATEST start
        fi
        exit 0
    fi
}

usage () {
    echo "mutt2task.sh <args>"
    echo
    echo "Simple script that converts a neomutt e-mail to a taskwarrior task"
    echo "The sender and subject of the e-mail are added as an annotation"
    echo "All arguments apart from -s and -h are passed to taskwarrior"
    echo
    echo "Options:"
    echo
    echo "-s: start task after adding"
    echo "-h: print this help message and exit"
}

if [ "$#" -le 1 ]
then
    echo "At least one argument is necessary. Exiting"
    exit 1
fi

# parse options
while getopts "sh" OPTION
do
    case $OPTION in
        s)
            start_task="yes"
            ;;
        h)
            echo "Nothing to do."
            usage
            exit 1
            ;;
        ?)
            echo "Nothing to do."
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

get_info
process_task "$@"
