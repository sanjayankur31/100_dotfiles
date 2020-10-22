#!/bin/bash

# Copyright 2020 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : bin/neomutt-compose.sh
#
# Trick to reply to e-mails in a different tmux window
# https://github.com/neomutt/neomutt/issues/2713

RNDNEW="$(date +%H%M)"
tmux new-window -ad -n "neomutt-$RNDNEW" neomutt && tmux swap-window -d -t +1 && vimx "$@"
