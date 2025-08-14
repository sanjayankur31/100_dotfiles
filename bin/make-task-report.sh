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

OUTPUTDIRDEFAULT="${HOME}/Sync/taskreports/"
#
# if no date is provided, assume today/now
ENDDATEDEFAULT=$(date +%Y-%m-%d -d "now")
NOWTIME=$(date +%Y-%m-%dT%H:%M)

mkdir -pv ${OUTPUTDIR}/


function taskreports() {
    # Update list as required
    for p in "foss" "job.ucl" "research" "personal"
    do
        ${HOME}/bin/generate-taskreports.sh -p $p | ansi2html -w > ${OUTPUTDIR}/taskreport-$p-$ENDDATE.html
    done
    # Generate combined report for everything
    ${HOME}/bin/generate-taskreports.sh -a | ansi2html -w > ${OUTPUTDIR}/taskreport-all-$ENDDATE.html

}

function timesheets() {
    echo "Generating time sheets ending ${ENDDATE}"
    week_start=$(date +%Y-%m-%d -d "${ENDDATE} - 1 week")
    month_start=$(date +%Y-%m-%d -d "${ENDDATE} - 1 month")

    # Time sheets
    # Can be split out into a different file perhaps
    echo > ${OUTPUTDIR}/timesheet-$ENDDATE.html
    echo " -- Week: totals --" >> ${OUTPUTDIR}/timesheet-$ENDDATE.html
    /usr/bin/timew report totals.py :week | ansi2html -w >> ${OUTPUTDIR}/timesheet-$ENDDATE.html

    echo >> ${OUTPUTDIR}/timesheet-$ENDDATE.html
    for p in "foss" "job" "research" "personal" "volunteering" "career-development"
    do
        echo " -- Week: $p --" >> ${OUTPUTDIR}/timesheet-$ENDDATE.html
        /usr/bin/timew summary "${week_start}" - "${ENDTIMESTAMP}" "$p" | ansi2html -w >> ${OUTPUTDIR}/timesheet-$ENDDATE.html
    done

    echo " -- Week: all --" >> ${OUTPUTDIR}/timesheet-$ENDDATE.html
    /usr/bin/timew summary "${week_start}" - "${ENDTIMESTAMP}" | ansi2html -w >> ${OUTPUTDIR}/timesheet-$ENDDATE.html

    echo >> ${OUTPUTDIR}/timesheet-$ENDDATE.html
    echo >> ${OUTPUTDIR}/timesheet-$ENDDATE.html
    echo " -- Month: totals --" >> ${OUTPUTDIR}/timesheet-$ENDDATE.html
    /usr/bin/timew report totals.py :month | ansi2html -w >> ${OUTPUTDIR}/timesheet-$ENDDATE.html

    echo >> ${OUTPUTDIR}/timesheet-$ENDDATE.html
    for p in "foss" "job" "research" "personal"
    do
        echo " -- Month: $p --" >> ${OUTPUTDIR}/timesheet-$ENDDATE.html
        /usr/bin/timew summary "${month_start}" - "${ENDTIMESTAMP}" "$p" | ansi2html -w >> ${OUTPUTDIR}/timesheet-$ENDDATE.html
    done

    echo " -- Month: all --" >> ${OUTPUTDIR}/timesheet-$ENDDATE.html
    /usr/bin/timew summary "${month_start}" - "${ENDTIMESTAMP}" | ansi2html -w >> ${OUTPUTDIR}/timesheet-$ENDDATE.html

}

usage () {
    echo "make-task-report.sh [-do] [-twh]"
    echo
    echo "Script generates a task and time sheet reports"
    echo
    echo "Options:"
    echo
    echo "-d <date>: date to use as end date/time for time sheets: if not supplied, use today's date and current time"
    echo "-o <outputdir>: location to save generated files to"
    echo "-t: generate only task reports assuming today's date and current time"
    echo "-w: generate only timew reports assuming today's date and current time"
    echo "-h: print this help message and exit"
}

# parse options
while getopts "twd:o:h" OPTION
do
    case $OPTION in
        t)
            ENDDATE=${ENDDATEINPUT:-$ENDDATEDEFAULT}
            ENDTIMESTAMP=${ENDDATEINPUT:-$NOWTIME}
            OUTPUTDIR=${OUTPUTDIRINPUT:-$OUTPUTDIRDEFAULT}
            taskreports
            exit 0
            ;;
        w)
            ENDDATE=${ENDDATEINPUT:-$ENDDATEDEFAULT}
            ENDTIMESTAMP=${ENDDATEINPUT:-$NOWTIME}
            OUTPUTDIR=${OUTPUTDIRINPUT:-$OUTPUTDIRDEFAULT}
            timesheets
            exit 0
            ;;
        o)
            OUTPUTDIRINPUT="$OPTARG"
            ;;
        d)
            ENDDATEINPUT="$OPTARG"
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


ENDDATE=${ENDDATEINPUT:-$ENDDATEDEFAULT}
ENDTIMESTAMP=${ENDDATEINPUT:-$NOWTIME}
OUTPUTDIR=${OUTPUTDIRINPUT:-$OUTPUTDIRDEFAULT}
taskreports
timesheets
