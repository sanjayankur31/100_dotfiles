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
# File : recordingsRename.sh
#

# Rename to remove all spaces. The file name should normally have only 3 spaces but I'm running it ten times just to be sure.

for i in {1..10}; 
do 
    echo "$i" ;
    rename " " "-" * ;
done 

# rename the files
for i in `ls My*`;
do 
    Accesstime=$(ls --full-time "${i}" | awk '{print $6}'); 
    checkSUM=$(md5sum "${i}" | awk '{print $1}'); 
    newName="${Accesstime}-${checkSUM}.wav"; 
    mv "${i}" "${newName}" -v;  
done

