#!/bin/bash

# Copyright 2021 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File :  fedora-install-texlive-deps.sh
# Install Texlive dependencies for a LaTeX project on Fedora
#
# Note that this is a dumb parser, in the sense that it does not actually parse
# the LaTeX text to "understand" it. It simply uses regular expressions to
# extract patterns from the package commands. So, for example, it will *not*
# ignore LaTeX comments.  So, it may report an over approximation of the
# required packages.
#
# Uses commonly used Linux utilities: grep, sed

REQUIREPACKAGES=""
USEPACKAGES=""

function fetchdeps() {
    REQUIREPACKAGES=$(grep -rhiI "requirepackage" *.tex *.cls *.sty 2>/dev/null | grep -oE "\{.*\}" | sed -e 's/,/}{/g' | sed -e "s/{/tex(/g" -e "s/}/.sty) /g" | tr '\n' ' ')
    REQUIREPACKAGES=${REQUIREPACKAGES}
    USEPACKAGES=$(grep -rhiI "usepackage" *.tex *.cls *.sty 2>/dev/null | grep -oE "\{.*\}" | sed -e 's/,/}{/g' | sed -e "s/{/tex(/g" -e "s/}/.sty) /g" | tr '\n' ' ')
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
    echo "-h: print this help text and exit"
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
