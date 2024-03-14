#!/bin/bash

# Copyright 2024 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File :  bin/byobus.sh
# Start my default sessions
#
# it's possible to do this in .byobu/windows.tmux.* also apparently, but I cannot get that to work

SESSION_NAME=""
default ()
{
    byobu new-session -s "default" -d
    tmux new-window -n "weechat" -t default: 'systemd-run --user --scope bash -i -c "weechat"'
    tmux new-window -n "eod" -t default: 'systemd-run --user --scope bash -i -c "vit-tl-today"'
    tmux new-window -n "eow" -t default: 'systemd-run --user --scope bash -i -c "vit-tl-this-week"'
    tmux new-window -n "1w" -t default: 'systemd-run --user --scope bash -i -c "vit-tl-in-a-week"'
    tmux new-window -n "eom" -t default: 'systemd-run --user --scope bash -i -c "vit-tl-this-month"'
    tmux new-window -n "1m" -t default: 'systemd-run --user --scope bash -i -c "vit-tl-in-a-month"'
    tmux new-window -n "all" -t default: 'systemd-run --user --scope bash -i -c "vit-tl"'
    tmux new-window -n "neomutt" -t default: 'systemd-run --user --scope bash -i -c "neomutt-work"'
    tmux new-window -t default:
    tmux kill-window -t default:0
    tmux move-window -r
    byobu at -t "default"
}
research ()
{
    byobu new-session -s "research" -d
    tmux new-window -n "rl" -t research: 'systemd-run --user --scope bash -i -c "vit-rl"'
    tmux new-window -n "newsboat" -t research: 'systemd-run --user --scope bash -i -c "newsboat"'
    tmux new-window -n "j" -t research:
    tmux new-window -n "projs" -t research:
    tmux new-window -n "ideas" -t research:
    tmux new-window -n "tj" -t research:
    tmux new-window -t research:
    tmux kill-window -t research:0
    tmux move-window -r
    byobu at -t "research"
}

newnamed ()
{
    byobu new-session -s "${SESSION_NAME}"
}

usage ()
{
    echo "byobus.sh: run my usual byobu sessions"
    echo
    echo "Options:"
    echo
    echo "-h: print this help"
    echo "-d: default session"
    echo "-r: research session"
    echo "-n <name>: new named session"
}

# parse options
while getopts "drn:h" OPTION
do
    case $OPTION in
        d)
            default
            exit 0
            ;;
        r)
            research
            exit 0
            ;;
        n)
            SESSION_NAME=$OPTARG
            newnamed
            exit 0
            ;;
        h)
            usage
            exit 0
            ;;
        ?)
            echo "Nothing to do."
            usage
            exit 1
            ;;
    esac
done

usage
exit 0
