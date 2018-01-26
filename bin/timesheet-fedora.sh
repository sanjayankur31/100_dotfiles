#!/bin/bash

# Copyright 2010 Ankur Sinha 
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
# File : timesheet.sh
#
# This generates timesheet data for my fedora tasks only
#

#!/bin/bash
 
source /home/asinha/.bashrc
 
phrase="1-weeks-ago"
#fmt="%m/%d/%Y"
fmt="%Y-%m-%d"
start=$(date +$fmt -d $phrase)
end=$(date +$fmt)
project_filter='(project:fedora or project:rpmfusion or project:fudcon)'

echo " (generated at $(date))"
echo
echo " -- Upcoming tasks - Today  -- "
filter="$project_filter due:today"
/usr/bin/task next $filter

echo
echo
echo " -- Upcoming tasks - This week -- "
filter="$project_filter due.before:eow due.after:today"
/usr/bin/task next $filter

echo
echo
echo " -- Overdue tasks -- "
filter="$project_filter overdue"
/usr/bin/task next $project_filter
 
echo
echo
echo " -- Tasks completed from $start to $end (back $phrase) -- "
/usr/bin/task work_report $project_filter end.after:$start
 
echo
echo
filter="$project_filter"
echo " -- Blocked tasks -- "
/usr/bin/task blocked $filter

echo
echo
echo " -- Blocking tasks -- "
/usr/bin/task blocking $filter

echo
echo
echo " -- Summary -- "
/usr/bin/task summary $filter
 
echo
echo
echo " -- History -- "
/usr/bin/task history $filter
/usr/bin/task ghistory $filter
/usr/bin/task burndown.daily
/usr/bin/task burndown
