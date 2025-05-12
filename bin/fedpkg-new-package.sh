#!/bin/bash

# Copyright 2025 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : bin/fedpkg-new-package.sh
#
# Create a new GitHub repo for a spec and set up the local directory

set -e

GITHUB_USER="sanjayankur31"
REMOTE_URL_BASE="git@github.com"

if ! command -v gh &> /dev/null
then
    echo ">> gh not found. Please install gh:"
    echo ">> sudo dnf install gh"
    exit -1
fi

if ! command -v git &> /dev/null
then
    echo ">> git not found. Please install git:"
    echo ">> sudo dnf install git-core"
    exit -1
fi

create_and_checkout ()
{
    REMOTE_URL="${REMOTE_URL_BASE}:${GITHUB_USER}"
    echo "Cloning/creating GitHub repository: ${REMOTE_URL}/${PACKAGENAME}"
    gh repo clone "${PACKAGENAME}" || gh repo create --clone --public "${PACKAGENAME}" -d "WIP spec for ${PACKAGENAME}"

    pushd "${PACKAGENAME}"
        git remote -v
    popd
}

usage () {
    echo
    echo "$(basename $0): -n <package name> [-g <GitHub username>] [-h]"
    echo
    echo "Init a new package repo and remote"
    echo
    echo "Usage:"
    echo
    echo "-h: print help and exit"
    echo "-n <package name>"
    echo "   name of package"
    echo "-g <GitHub user>"
    echo "   GitHub username"

}

if [ $# -lt 1 ]
then
    usage
    exit -1
fi

while getopts "n:hg:" OPTION
do
    case $OPTION in
        n)
            PACKAGENAME="$OPTARG"
            ;;
        g)
            GITHUB_USER="$OPTARG"
            ;;
        h)
            usage
            exit 0
            ;;
    esac
done


create_and_checkout
