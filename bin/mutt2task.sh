#!/usr/bin/bash
# add a email from mutt to taskwarrior
sender=""
subject=""
# default project
project="email"
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
        task add project:$project due:2d "$sender: $subject"
        # Start task if needed
        if [ "$start_task" = "yes" ]; then
            task +LATEST start
        fi
        exit 0
    fi
}

usage () {
    echo "mutt2task.sh [-p] [-s]"
    echo
    echo "Simple script that converts a neomutt e-mail to a taskwarrior task"
    echo
    echo "Options:"
    echo
    echo "-p <project name>: project to add task to; default: email"
    echo "-s: start task after adding"
    echo "-h: print this help message and exit"
}

# parse options
while getopts "p:sh" OPTION
do
    case $OPTION in
        p)
            project=$OPTARG
            ;;
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

get_info
process_task
