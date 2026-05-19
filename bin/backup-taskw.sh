#!/bin/bash

# Copyright 2025 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File : backup taskwarrior database
#

timestamp="$(date +%Y%m%d%H%M)"
filename="taskchampion.sqlite3"
backupdir="${HOME}/Sync/task-backup/"

# update mtime of the db for syncing
# echo "Pending tasks: $(task status:pending count)"

pushd ~/.task/ && cp -av  "${filename}" "${backupdir}/${filename}.${timestamp}.$HOSTNAME" && popd
find "${backupdir}" -name "${filename}.*.$HOSTNAME" -mtime +28 -printf "removed '%f'\n " -delete
