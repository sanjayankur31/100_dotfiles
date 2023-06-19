#!/bin/bash

# Copyright 2023 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : bin/fedpkg-sync-build-all-branches.sh
#
# Just a shortcut so I don't have to write the for loop each time myself.
#

branches=""
UPDATE_NOTE="meh"
TYPE="bugfix"
PACKAGE_NAME="$(basename *.spec .spec)"

if ! command -v fedrq &> /dev/null
then
    echo "fedrq not found. Please install fedrq:"
    echo "sudo dnf install fedrq"
    exit -1
fi

if ! command -v fedpkg &> /dev/null
then
    echo "fedpkg not found! Exiting."
    exit -1
fi

run () {
    if [ "" == "${branches}" ]
    then
        echo "No branches suplied. Exiting"
        usage
        exit -1
    fi

    echo "Updating repo and rebasing"
    git checkout rawhide
    git pull --rebase

    for branch in $branches
    do
        echo "Working on branch: ${branch}"

        echo "Checking update impact using fedrq"
        echo "The following packages will be affected. Please ensure that they do not break as a result of this update:"
        fedrq whatrequires-src -b "${branch}" -F breakdown "${PACKAGE_NAME}"

        echo "Do you wish to proceed with the update for ${branch}?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) break;;
                No ) echo "Not proceeding with update for ${branch}"; continue 2;;
            esac
        done

        if  [ "meh" == "${UPDATE_NOTE}" ]
        then
            echo "Merging and building"
            fedpkg switch-branch "$branch" && git pull && git merge rawhide && git push && fedpkg build || exit -1
        else
            echo "Merging, building, creating update"
            fedpkg switch-branch "$branch" && git pull && git merge rawhide && git push && fedpkg build && fedpkg update --type "${TYPE}" --notes "${UPDATE_NOTE}" || exit -1
    fi
    done
}

usage () {
    echo "Usage: "
    echo "$0 [-ut] <branches to sync with rawhide>"
    echo
    echo "Options:"
    echo "-u <update note>"
    echo "-t <update type>: see 'fedpkg update -h' for valid options"
    echo
    echo "Positional parameters:"
    echo "<branches to sync with rawhide>"
}

if [ $# -lt 1 ]
then
    echo "At least one positional argument is required"
    usage
    exit -1
fi

# parse options
# https://stackoverflow.com/questions/11742996/is-mixing-getopts-with-positional-parameters-possible
while getopts "u:t:h" OPTION
do
    case $OPTION in
        u)
            UPDATE_NOTE="$OPTARG"
            ;;
        t)
            TYPE="$OPTARG"
            ;;
        h)
            usage
            exit 0
            ;;
    esac
done

shift $(($OPTIND - 1))
branches="$@"
run
