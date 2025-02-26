#!/bin/bash

# Copyright 2025 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : bin/fedpkg-new-package.sh
#
# Create a new GitHub repo for a spec and set up the local directory

set -e

# default is GitHub
REMOTE_URL="git@github.com:sanjayankur31/"

create_and_checkout ()
{
    echo "Creating GitHub repository"
    gh repo create --public "${packagename}" -d "WIP spec for ${packagename}"

    mkdir -pv "${packagename}" && pushd "${packagename}"
    git init .
    git remote add origin "$REMOTE_URL/${packagename}.git"
}

usage () {
    echo "$0: <options>"
    echo
    echo "Init a new package repo and remote"
    echo
    echo "Usage:"
    echo
    echo "-h: print help and exit"
    echo "-n <package name>"
    echo "   name of package"

}

if [ $# -lt 1 ]
then
    usage
    exit -1
fi

while getopts "n:h" OPTION
do
    case $OPTION in
        n)
            packagename="$OPTARG"
            ;;
        h)
            usage
            exit 0
            ;;
    esac
done


create_and_checkout
