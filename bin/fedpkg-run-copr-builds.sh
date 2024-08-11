#!/bin/bash

# Copyright 2022 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File : fedpkg-run-copr-builds.sh
#
# Run copr builds for a specified list of packages. Useful when one wants to
# test rebuilding a bunch of dependencies when updating packages
#
# To be run in a folder containing the various SCM folders.
# Update variable names as required

PACKAGE_LIST_FILE="packages.txt"
FEDORA_BRANCH="rawhide"
COPR_PROJECT=""

dobuilds () {
    while read pkg ; do
        if ! [ -d "$pkg" ]
        then
            echo "> Checking out ${pkg}"
            fedpkg co "$pkg"
        fi
        echo "> Rebuilding ${pkg} in COPR project ${COPR_PROJECT} for branch ${FEDORA_BRANCH}"
        pushd "$pkg" && git clean -dfx && fedpkg switch-branch "${FEDORA_BRANCH}" && git reset HEAD --hard && git pull --rebase && fedpkg copr-build "${NOWAIT_OPT:+$NOWAIT_OPT}" "${COPR_PROJECT}" && popd
    done < "${PACKAGE_LIST_FILE}"
}

usage () {
    echo "$0"
    echo
    echo "-h: print help and exit"
    echo "-p <COPR project>"
    echo "-l <name of package list file to read from>"
    echo "   <default: packages.txt>"
    echo "-f <branch of SCM to build>"
    echo "   <default: rawhide>"
    echo "-n do not wait for each build to complete (uses --nowait)"
}

if [ $# -lt 1 ]
then
    echo "At least -p is required"
    usage
    exit -1
fi

# parse options
# https://stackoverflow.com/questions/11742996/is-mixing-getopts-with-positional-parameters-possible
while getopts "p:f:l:nh" OPTION
do
    case $OPTION in
        p)
            COPR_PROJECT="$OPTARG"
            ;;
        f)
            FEDORA_BRANCH="$OPTARG"
            ;;
        l)
            PACKAGE_LIST_FILE="$OPTARG"
            ;;
        n)
            NOWAIT_OPT="--nowait"
            ;;
        h)
            usage
            exit 0
            ;;
    esac
done

dobuilds
