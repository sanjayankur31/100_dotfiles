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
# File : make-report.sh 
# 
# Generates reporst from my task data
#

#!/bin/bash
 
today=$(date +%Y-%m-%d)
/home/asinha/bin/timesheet-fedora.sh | ansi2html > /tmp/timesheet-fedora.html
/home/asinha/bin/timesheet-research.sh | ansi2html > /tmp/timesheet-research.html
/home/asinha/bin/timesheet-misc.sh | ansi2html > /tmp/timesheet-misc.html

cp /tmp/timesheet-fedora.html ~/timesheets/$today-fedora.html
cp /tmp/timesheet-fedora.html ~/timesheets/latest-fedora.html

cp /tmp/timesheet-research.html ~/timesheets/$today-research.html
cp /tmp/timesheet-research.html ~/timesheets/latest-research.html

cp /tmp/timesheet-misc.html ~/timesheets/$today-misc.html
cp /tmp/timesheet-misc.html ~/timesheets/latest-misc.html

rm /tmp/timesheet*.html
