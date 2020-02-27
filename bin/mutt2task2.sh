#!/usr/bin/bash
# add a email from mutt to taskwarrior and start the task
# useful when you want to reply to an e-mail now but still want to track it
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
        subject="$(echo "$line" | grep "^Subject:" | sed -e  's/Subject://' -e 's/^[[:space:]]*//')"
        # subject="$(echo "$line" | sed -n '/^Subject:/ p;q')"
    fi
done

# there must be a sender, the subject may be empty
if [ -n "$sender" ]
then
    echo "$sender: $subject"
    output="$(task add project:email due:2d "$sender: $subject")"
    taskid="$(echo "$output" | grep -Eo "[[:digit:]]+")"
    task "$taskid" start
    exit 0
fi
