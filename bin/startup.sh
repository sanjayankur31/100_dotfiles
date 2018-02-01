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
# File : startup.sh
# This file will have commands that I'd like to run on login. Instead of
# individually adding them to the gnome-startup apps, I'll just run this 
# one file
#

if ! pgrep "mpdscribble" && pgrep "mpd$" ; then
   mpdscribble
fi

# tj3daemon
#if ! pgrep "tj3d" ; then
#    pushd /home/ankur/Documents/work/organize/planning/UTS_masters/tjplan
#    tj3d && sleep 1; tj3client add plan.tjp && tj3webd
#    popd
#fi
