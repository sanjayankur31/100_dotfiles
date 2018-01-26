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

# if ! pgrep -f "systemd --user" ; then
#     systemd --user &
# fi

#mpDris2 --debug >> ~/mpDris2.log 2>&1 &

#run rssdler
#if ! rssdler -s ; then
#	if [ -f "/home/ankur/Downloads/torrent-temps/daemon.info" ]; then
#		rm -fv "/home/ankur/Downloads/torrent-temps/daemon.info";
#	fi
#    rssdler -d
#fi

# rtorrentqueuemanager
#if ! pgrep -f "rtorrentQM" ; then
#	rm -fv "/home/ankur/.local/share/rtorrentQM/pid"
#    /home/ankur/bin/rtorrentQM.pl &
#fi

# Replaced by user systemd files
# mpd
# if ! pgrep "^mpd$" ; then
    # mpd &
# fi
#
# Ensure that mpd is running before starting the others
#sleep 5

# mpdas
#if ! pgrep "mpdscribble" ; then 
#    mpdscribble
#fi

# tj3daemon
#if ! pgrep "tj3d" ; then
#    pushd /home/ankur/Documents/work/organize/planning/UTS_masters/tjplan
#    tj3d && sleep 1; tj3client add plan.tjp && tj3webd
#    popd
#fi
#ret=`ps aux | egrep "task-web" | sed '/grep/ d' | wc -l`
#if [ ! $ret -gt 0 ]; then
#    task-web
#fi
