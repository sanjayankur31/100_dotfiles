#!/bin/bash

# Copyright 2020 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File : backup qutebrowser settings regularly

QUTE_DATADIR="$HOME/.local/share/qutebrowser/sessions/"
QUTE_CONFDIR="$HOME/.config/qutebrowser/"
QUTE_BACKUPDIR="$HOME/Sync/qutebrowser-backup/$HOSTNAME/"
timestamp="$(date +%Y%m%H%M)"

mkdir -p "$QUTE_BACKUPDIR" || exit -1

pushd "$QUTE_DATADIR" || exit -1
    cp default.yml "$QUTE_BACKUPDIR/$timestamp-default.yml"
popd

pushd "$QUTE_CONFDIR" || exit -1
    cp autoconfig.yml "$QUTE_BACKUPDIR/$timestamp-autoconfig.yml"
popd
