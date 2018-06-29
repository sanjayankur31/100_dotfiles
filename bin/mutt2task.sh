#!/usr/bin/bash
sender=""
subject=""

while IFS= read -r line
do
    if [ -z "$sender" ]
    then
        # sender="$(echo "$line" | sed -n '/^From:/ p;q')"
        sender="$(echo "$line" | grep "^From:" | awk -F: '{print $2}' | sed -e 's/^[[:space:]]*//')"
    fi
    if [ -z "$subject" ]
    then
        subject="$(echo "$line" | grep "^Subject:" | awk -F: '{print $2}' | sed -e 's/^[[:space:]]*//')"
        # subject="$(echo "$line" | sed -n '/^Subject:/ p;q')"
    fi

    if [ -n "$sender" ] && [ -n "$subject" ]
    then
        # echo "$sender: $subject"
        task add project:email due:1d "$sender: $subject"
        exit 0
    fi 
done
