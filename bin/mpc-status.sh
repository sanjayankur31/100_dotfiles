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
if [ -x /usr/bin/notify-send ]
then
	status=`mpc status | egrep playing`

	# check if playing
	if [ -n "$status" ]
	then
		notify-send -t 5 -i /usr/share/icons/gnome/scalable/actions/media-playback-start-symbolic.svg "MPD: Now Playing -> " "`mpc status | head -1`"
	else
		# is it paused
		if [ -n "`mpc status | egrep paused`" ]
		then
			notify-send -t 5 -i /usr/share/icons/gnome/scalable/actions/media-playback-pause-symbolic.svg "MPD: Paused -> " "`mpc status | head -1`"
		else 
			notify-send -t 5 -i /usr/share/icons/gnome/scalable/actions/media-playback-stop-symbolic.svg "MPD: Stopped!"
		fi
	fi
else
	echo "notify-send not installed"
	exit -1
fi

exit 0
