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
# File : 
#
if [ `mount | egrep "Ankur_Backup" | wc -l` -gt 0 ] ; 
then
    mountedLocation=$(mount | egrep Ankur_Backup | sed 's/ type.*$//' | sed 's/^.*on //')
    echo "*** [OK] Found Ankur Backup mounted at $mountedLocation."
    echo "*** [OK] Syncing Pictures"
    picturesBackup="$mountedLocation""/Pictures/"
    configBackup="$mountedLocation""/Config_files/"
    rsync --delete -avPh ~/Pictures/ $picturesBackup
    echo "*** [OK] Syncing configuration files"
    rsync --delete -avPh ~/.bashrc ~/.vimrc ~/.rtorrent.rc ~/.screenrc ~/.gitconfig $configBackup
else 
    echo "*** [Error] Ankur_Backup was not found."
fi

if [ `mount | egrep "Stuff" | wc -l` -gt 0 ] ; 
then
    mountedLocation=$(mount | egrep Stuff | sed 's/ type.*$//' | sed 's/^.*on //')
    musicBackup="$mountedLocation""/Music/"
    echo "*** [OK] Found Stuff mounted at $mountedLocation."
    echo "*** [OK] Syncing Music"
    rsync --delete -avPh ~/Music/ $musicBackup
else
    echo "*** [Error] Stuff was not found."
fi
