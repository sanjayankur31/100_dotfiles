#!/bin/bash

# Copyright 2021 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File :  bin/qute-block-hosts.sh
# Toggle blocking my list for qutebrowser

pushd ~/.config/qutebrowser
    if [ -f "blocked-hosts" ]
    then
        mv blocked-hosts blocked-hosts.disabled
    else
        mv blocked-hosts.disabled blocked-hosts
    fi
popd
