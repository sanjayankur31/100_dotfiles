#!/bin/bash

# Copyright 2025 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File : backup taskwarrior database
#

timestamp="$(date +%Y%m%d%H%M)"
filename="taskchampion.sqlite3"

# update mtime of the db for syncing
echo "Pending tasks: $(task status:pending count)"

pushd ~/.task/ && cp -av  "${filename}" "${filename}.${timestamp}" && popd
find ~/.task/ -name "${filename}.*" -mtime +28 -printf "removed '%f'\n " -delete
