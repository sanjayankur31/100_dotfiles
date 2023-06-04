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
#

OUTPUTDIR="${HOME}/Sync/taskreports/"

mkdir -pv ${OUTPUTDIR}/

function taskreports() {
    # Update list as required
    for p in "foss" "job.ucl" "research" "personal"
    do
        ${HOME}/bin/generate-taskreports.sh -p $p | ansi2html -w > ${OUTPUTDIR}/taskreport-$p-$enddate.html
    done
    # Generate combined report for everything
    ${HOME}/bin/generate-taskreports.sh -a | ansi2html -w > ${OUTPUTDIR}/taskreport-all-$enddate.html

}

function timesheets() {
    echo "Generating time sheets ending ${enddate}"
    week_start=$(date +%Y-%m-%d -d "${enddate} - 1 week")
    month_start=$(date +%Y-%m-%d -d "${enddate} - 1 month")

    # Time sheets
    # Can be split out into a different file perhaps
    echo > ${OUTPUTDIR}/timesheet-$enddate.html
    echo " -- Week: totals --" >> ${OUTPUTDIR}/timesheet-$enddate.html
    /usr/bin/timew report totals.py :week | ansi2html -w >> ${OUTPUTDIR}/timesheet-$enddate.html

    echo >> ${OUTPUTDIR}/timesheet-$enddate.html
    for p in "foss" "job" "research" "personal" "volunteering" "career-development"
    do
        echo " -- Week: $p --" >> ${OUTPUTDIR}/timesheet-$enddate.html
        /usr/bin/timew summary "${week_start}" - "${endtimestamp}" "$p" | ansi2html -w >> ${OUTPUTDIR}/timesheet-$enddate.html
    done

    echo " -- Week: all --" >> ${OUTPUTDIR}/timesheet-$enddate.html
    /usr/bin/timew summary "${week_start}" - "${endtimestamp}" | ansi2html -w >> ${OUTPUTDIR}/timesheet-$enddate.html

    echo >> ${OUTPUTDIR}/timesheet-$enddate.html
    echo >> ${OUTPUTDIR}/timesheet-$enddate.html
    echo " -- Month: totals --" >> ${OUTPUTDIR}/timesheet-$enddate.html
    /usr/bin/timew report totals.py :month | ansi2html -w >> ${OUTPUTDIR}/timesheet-$enddate.html

    echo >> ${OUTPUTDIR}/timesheet-$enddate.html
    for p in "foss" "job" "research" "personal"
    do
        echo " -- Month: $p --" >> ${OUTPUTDIR}/timesheet-$enddate.html
        /usr/bin/timew summary "${month_start}" - "${endtimestamp}" "$p" | ansi2html -w >> ${OUTPUTDIR}/timesheet-$enddate.html
    done

    echo " -- Month: all --" >> ${OUTPUTDIR}/timesheet-$enddate.html
    /usr/bin/timew summary "${month_start}" - "${endtimestamp}" | ansi2html -w >> ${OUTPUTDIR}/timesheet-$enddate.html

}

usage () {
    echo "make-task-report.sh [-t] [-h]"
    echo
    echo "Script generates a task and time sheet reports"
    echo
    echo "Options:"
    echo
    echo "-t <date>: date to use as end date/time for time sheets: if not supplied, use today's date and current time"
    echo "-h: print this help message and exit"
}

# parse options
while getopts "t:h" OPTION
do
    case $OPTION in
        t)
            enddateinput="$OPTARG"
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


# if no date is provided, assume today/now
enddatedefault=$(date +%Y-%m-%d -d "enddate")
nowtime=$(date +%Y-%m-%dT%H:%M)
enddate=${enddateinput:-$enddatedefault}
endtimestamp=${enddateinput:-$nowtime}
taskreports
timesheets
