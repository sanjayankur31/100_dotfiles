#!/bin/bash

# Copyright 2025 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : update-machine.sh
#
# Script to run various update commands
#
#

OFFLINE_UPDATE="yes"


update_pass () {
    echo ">>> Update pass"
    pass git pull ; pass git push
}

update_vim () {
    echo ">>> Update vim"
    set -e
    pushd ~/.vim

    git clean -dfx && git pull && git push

    # update vim-plug
    vim "+:PlugUpgrade" "+:qall"
    if [ -e "autoload/plug.vim.old" ]
    then
        rm -f autoload/plug.vim.old && git add autoload/plug.vim && git commit -m "chore: update vim-plug" && git push
    fi

    vim '+:PlugClean!' "+:PlugInstall" "+:PlugUpdate" "+:qall"
    popd

    set +e
}

update_dots () {
    echo ">>> Update dotfiles"
    pushd ~/.dotfiles && git clean -df && git pull && git push && popd && rcup -v
}

update_packages () {
    if [ "yes" == "$OFFLINE_UPDATE" ]
    then
        echo ">>> Update dnf packages (offline)"
        sudo dnf offline-upgrade --refresh -y download
    else
        echo ">>> Update dnf packages (online)"
        sudo dnf update -y --refresh
    fi
}

update_flatpaks () {
    echo ">>> Update flatpaks"
    flatpak --user uninstall --unused -y
    flatpak --user update -y
}

usage () {
    echo "$(basename $0): [-pvdnNfaA]"
    echo
    echo "Run common update tasks"
    echo
    echo "Usage:"
    echo
    echo "-p: update pass"
    echo "-v: update vim config and plugins"
    echo "-d: update dotfiles"
    echo "-n: update dnf packages offline (reboot to complete)"
    echo "-N: update dnf packages online (no reboot)"
    echo "-f: update flatpaks"
    echo "-a: update all (with offline dnf)"
    echo "-A: update all (with online dnf)"
    echo "-h: print help and exit"
}


if [ $# -lt 1 ]
then
    usage
    exit -1
fi

while getopts "hpvdnNfaA" OPTION
do
    case $OPTION in
        p)
            update_pass
            exit 0
            ;;
        v)
            update_vim
            exit 0
            ;;
        d)
            update_dots
            exit 0
            ;;
        n)
            update_packages
            exit 0
            ;;
        N)
            OFFLINE_UPDATE="no"
            update_packages
            exit 0
            ;;
        f)
            update_flatpaks
            exit 0
            ;;
        a)
            update_pass
            update_vim
            update_dots
            update_packages
            update_flatpaks
            exit 0
            ;;
        A)
            OFFLINE_UPDATE="no"
            update_pass
            update_vim
            update_dots
            update_packages
            update_flatpaks
            exit 0
            ;;
        h)
            usage
            exit 0
            ;;
    esac
done


