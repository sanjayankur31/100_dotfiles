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

today=$(date +%Y-%m-%d)

mkdir -pv ~/Sync/taskreports/

# Update list as required
for p in "foss" "job.ucl" "research" "ocns" "personal"
do
    /home/asinha/bin/generate-taskreports.sh -p $p | ansi2html -w > ~/Sync/taskreports/taskreport-$p-$today.html
done
# Generate combined report for everything
/home/asinha/bin/generate-taskreports.sh -a | ansi2html -w > ~/Sync/taskreports/taskreport-all-$today.html

# Time sheets
# Can be split out into a different file perhaps
echo > ~/Sync/taskreports/timesheet-$today.html
for p in "foss" "job" "research" "ocns" "personal"
do
    echo " -- Week: $p --" >> ~/Sync/taskreports/timesheet-$today.html
    /usr/bin/timew summary :week "$p" | ansi2html -w >> ~/Sync/taskreports/timesheet-$today.html
done
echo " -- Week: all --" >> ~/Sync/taskreports/timesheet-$today.html
/usr/bin/timew summary :week | ansi2html -w >> ~/Sync/taskreports/timesheet-$today.html

echo >> ~/Sync/taskreports/timesheet-$today.html
echo >> ~/Sync/taskreports/timesheet-$today.html
for p in "foss" "job" "research" "ocns" "personal"
do
    echo " -- Month: $p --" >> ~/Sync/taskreports/timesheet-$today.html
    /usr/bin/timew summary :month "$p" | ansi2html -w >> ~/Sync/taskreports/timesheet-$today.html
done
echo " -- Month: all --" >> ~/Sync/taskreports/timesheet-$today.html
/usr/bin/timew summary :month | ansi2html -w >> ~/Sync/taskreports/timesheet-$today.html
