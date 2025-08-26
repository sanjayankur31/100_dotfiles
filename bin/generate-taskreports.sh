#!/bin/bash

# Copyright 2020 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File : generate-taskreports.sh

fmt="%Y-%m-%d"
phrase_last_week="1-weeks-ago"
start_last_week=$(date +$fmt -d $phrase_last_week)
phrase_last_year="1-years-ago"
start_last_year=$(date +$fmt -d $phrase_last_year)
end=$(date +$fmt)
project_filter=""
rcoptions="rc.gc=0 rc.defaultwidth=150 rc.defaultheight=120"


function get_task_data ()
{
    current_context="$(task "$rcoptions" context | grep "yes" | cut -d " " -f1)"
    # Unset context
    /usr/bin/task "$rcoptions" context none

    echo " (generated at $(date))"
    echo
    echo " -- Overdue tasks -- "
    filter="$project_filter"
    /usr/bin/task "$rcoptions" $filter overdue

    echo
    echo
    echo " -- Upcoming tasks - Today  -- "
    filter="$project_filter due:eod"
    /usr/bin/task "$rcoptions" $filter list

    echo
    echo
    echo " -- Upcoming tasks - 1 week -- "
    filter="$project_filter due.by:$(date +%Y-%m-%d --date '1 week')"
    /usr/bin/task "$rcoptions" $filter list

    echo
    echo
    echo " -- Upcoming tasks - 1 month -- "
    filter="$project_filter due.by:$(date +%Y-%m-%d --date '1 month')"
    /usr/bin/task "$rcoptions" $filter list

    echo
    echo
    echo " -- Upcoming tasks - 6 months -- "
    filter="$project_filter due.by:$(date +%Y-%m-%d --date '6 month')"
    /usr/bin/task "$rcoptions" $filter list

    echo
    echo
    echo " -- Tasks completed from $start_last_week to $end (back $phrase_last_week) -- "
    filter="$project_filter end.after:$start_last_week"
    /usr/bin/task "$rcoptions" $filter completed

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
    filter="$project_filter entry.after:$start_last_year"
    echo " -- History (since $start_last_year)-- "
    /usr/bin/task "$rcoptions" history $filter
    /usr/bin/task "$rcoptions" ghistory $filter
    /usr/bin/task "$rcoptions" $filter burndown.daily
    /usr/bin/task "$rcoptions" $filter burndown


    # Reset context
    /usr/bin/task "$rcoptions" context "${current_context}"
}

usage () {
    echo "generate-taskreports.sh [-p] [-h]"
    echo
    echo "Script generates a taskreport from taskwarrior output"
    echo
    echo "Options:"
    echo
    echo "-p <project name>: project to generate taskreport for"
    echo "-a generate combined time sheet including all projects"
    echo "-h: print this help message and exit"
}


if [ $# -eq 0 ]
then
    echo "You did not tell me what to do. Exiting."
    usage
    exit 0
fi

# parse options
while getopts "ap:h" OPTION
do
    case $OPTION in
        p)
            project_filter="project~$OPTARG"
            get_task_data
            exit 0
            ;;
        a)  get_task_data
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
