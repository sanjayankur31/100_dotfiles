#!/bin/bash

# Copyright 2020 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File : generate-timesheets.sh

phrase="1-weeks-ago"
fmt="%Y-%m-%d"
start=$(date +$fmt -d $phrase)
end=$(date +$fmt)
project_filter=""
rcoptions="rc.defaultwidth=200 rc.defaultheight=120"


function get_task_data ()
{
    echo " (generated at $(date))"
    echo
    echo " -- Upcoming tasks - Today  -- "
    filter="$project_filter due:today"
    /usr/bin/task "$rcoptions" $filter next

    echo
    echo
    echo " -- Upcoming tasks - This week -- "
    filter="$project_filter due.before:eow due.after:today"
    /usr/bin/task "$rcoptions" $filter next

    echo
    echo
    echo " -- Overdue tasks -- "
    filter="$project_filter overdue"
    /usr/bin/task "$rcoptions" $project_filter next

    echo
    echo
    echo " -- Tasks completed from $start to $end (back $phrase) -- "
    /usr/bin/task "$rcoptions" work_report $project_filter end.after:$start

    echo
    echo
    filter="$project_filter"
    echo " -- Blocked tasks -- "
    /usr/bin/task "$rcoptions" $filter blocked

    echo
    echo
    echo " -- Blocking tasks -- "
    /usr/bin/task "$rcoptions" $filter blocking

    echo
    echo
    echo " -- Summary -- "
    /usr/bin/task "$rcoptions" $filter summary

    echo
    echo
    echo " -- History -- "
    /usr/bin/task "$rcoptions" history $filter
    /usr/bin/task "$rcoptions" ghistory $filter
    /usr/bin/task "$rcoptions" $filter burndown.daily
    /usr/bin/task "$rcoptions" $filter burndown

}

usage () {
    echo "generate-timesheets.sh [-p] [-h]"
    echo
    echo "Script generates a timesheet from taskwarrior output"
    echo
    echo "Options:"
    echo
    echo "-p <project name>: project to generate timesheet for"
    echo "-h: print this help message and exit"
}


if [ $# -eq 0 ]
then
    echo "You did not tell me what to do. Exiting."
    usage
    exit 0
fi

# parse options
while getopts "p:h" OPTION
do
    case $OPTION in
        p)
            project_filter="project:$OPTARG"
            get_task_data
            exit 0
            ;;
        h)
            usage
            exit 0
            ;;
        ?)
            echo "Nothing to do."
            usage
            exit 1
            ;;
    esac
done
