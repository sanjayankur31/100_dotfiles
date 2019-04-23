#!/bin/bash

# Copyright 2019 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File :  fedora-install-texlive-deps.sh
# Install Texlive dependencies for a LaTeX project on Fedora

REQUIREPACKAGES=""
USEPACKAGES=""

function fetchdeps() {
    REQUIREPACKAGES=$(grep -rhiI "requirepackage" * 2>/dev/null | sed -e "s|^.*\\\RequirePackage.*{|tex(|" -e "s|}.*$|\.sty)|" | uniq -u | tr '\n' ' ')
    REQUIREPACKAGES=${REQUIREPACKAGES}
    USEPACKAGES=$(grep -rhiI "usepackage" * 2>/dev/null | sed -e "s|^.*\\\usepackage.*{|tex(|" -e "s|}.*$|\.sty)|" | uniq -u | tr '\n' ' ')
    USEPACKAGES=${USEPACKAGES}

    echo "Following packages detected: $REQUIREPACKAGES $USEPACKAGES"
}

function installdeps() {
    sudo dnf install $REQUIREPACKAGES $USEPACKAGES --setopt=strict=0
}


function usage() {
    echo "$0: Install required Texlive packages for a LaTeX project on Fedora"
    echo
    echo "Usage: $0 [-di]"
    echo
    echo "-d: dry run, only print required packages"
    echo "-i: also attempt to install packages"
}

if [ $# -ne 1 ]
then
    usage
    exit 1
fi

# parse options
while getopts "dih" OPTION
do
    case $OPTION in
        d)
            fetchdeps
            exit 0
            ;;
        i)
            fetchdeps
            installdeps
            exit 0
            ;;
        h)
            usage
            exit 1
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done
