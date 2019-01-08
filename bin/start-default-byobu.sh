#!/bin/bash

tmux new-session -d -s 'byobu-default'
tmux new-window -n 'ncmpcpp' 'ncmpcpp'
tmux new-window -n 'weechat' 'weechat'
tmux new-window -n 'neomutt' 'neomutt'
tmux new-window -n 't-l' 'vit project!~literature'
tmux new-window -n 'r-l' 'vit project~literature'
