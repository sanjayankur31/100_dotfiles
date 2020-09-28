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

mkdir -pv ~/Sync/timesheets/

# Update list as required
for p in "foss" "job.ucl" "research" "ocns" "personal"
do
    /home/asinha/bin/generate-timesheets.sh -p $p | ansi2html -w > ~/Sync/timesheets/timesheet-$p-$today.html
done
