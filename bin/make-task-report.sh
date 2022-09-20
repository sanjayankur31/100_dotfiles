#!/bin/bash

# Copyright 2020 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# File : make-task-report.sh
#
# Generates reports from my task data
#

#!/bin/bash

mkdir -pv ~/Sync/taskreports/

function taskreports() {
    # Update list as required
    for p in "foss" "job.ucl" "research" "personal"
    do
        /home/asinha/bin/generate-taskreports.sh -p $p | ansi2html -w > ~/Sync/taskreports/taskreport-$p-$today.html
    done
    # Generate combined report for everything
    /home/asinha/bin/generate-taskreports.sh -a | ansi2html -w > ~/Sync/taskreports/taskreport-all-$today.html

}

function timesheets() {
    echo "Generating time sheets ending ${today}"
    week_start=$(date +%Y-%m-%d -d "${today} - 1 week")
    month_start=$(date +%Y-%m-%d -d "${today} - 1 month")

    # Time sheets
    # Can be split out into a different file perhaps
    echo > ~/Sync/taskreports/timesheet-$today.html
    for p in "foss" "job" "research" "personal" "volunteering" "career-development"
    do
        echo " -- Week: $p --" >> ~/Sync/taskreports/timesheet-$today.html
        /usr/bin/timew summary "${week_start}" - "${today}" "$p" | ansi2html -w >> ~/Sync/taskreports/timesheet-$today.html
    done
    echo " -- Week: all --" >> ~/Sync/taskreports/timesheet-$today.html
    /usr/bin/timew summary "${week_start}" - "${today}" | ansi2html -w >> ~/Sync/taskreports/timesheet-$today.html

    echo >> ~/Sync/taskreports/timesheet-$today.html
    echo >> ~/Sync/taskreports/timesheet-$today.html
    for p in "foss" "job" "research" "personal"
    do
        echo " -- Month: $p --" >> ~/Sync/taskreports/timesheet-$today.html
        /usr/bin/timew summary "${month_start}" - "${today}" "$p" | ansi2html -w >> ~/Sync/taskreports/timesheet-$today.html
    done
    echo " -- Month: all --" >> ~/Sync/taskreports/timesheet-$today.html
    /usr/bin/timew summary "${month_start}" - "${today}" | ansi2html -w >> ~/Sync/taskreports/timesheet-$today.html
}

usage () {
    echo "make-task-report.sh [-t] [-h]"
    echo
    echo "Script generates a task and time sheet reports"
    echo
    echo "Options:"
    echo
    echo "-t <date>: date to use as 'todays' for time sheets: if not supplied, use today's date"
    echo "-h: print this help message and exit"
}

# parse options
while getopts "t:h" OPTION
do
    case $OPTION in
        t)
            todayinput="$OPTARG"
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


# if no date is provided, assume today
todaysdate=$(date +%Y-%m-%d -d "today")
today=${todayinput:-$todaysdate}
taskreports
timesheets
