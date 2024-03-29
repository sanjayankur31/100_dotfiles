#!/bin/bash
# search-tw-projects.sh
# use wofi/rofi/fzf to quickly search through tw projects

PROJECT=$(task _unique project | fzf)
# set the tmux buffer
tmux set-buffer `echo $PROJECT`
# set wayland/x buffers
if [ "$XDG_SESSION_TYPE" == "wayland" ]
then
    echo $PROJECT | wl-copy
elif [ "$XDG_SESSION_TYPE" == "x11" ]
then
    echo $PROJECT | xsel -i
fi

