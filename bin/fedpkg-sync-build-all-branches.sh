#!/bin/bash

# Copyright 2023 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : bin/fedpkg-sync-build-all-branches.sh
#
# Just a shortcut so I don't have to write the for loop each time myself.
#
#

if ls *.spec > /dev/null 2>&1
then
    PACKAGE_NAME="$(basename *.spec .spec)"
    echo "Working on package ${PACKAGE_NAME}"
else
    echo "Could not find a spec file in this folder. Exiting"
    exit 1
fi

branches=""
UPDATE_NOTE="meh"
TYPE="bugfix"
IMPACT_CHECK="No"
IMPACT_CHECKED="No"

if ! command -v fedrq &> /dev/null
then
    echo ">> fedrq not found. Please install fedrq:"
    echo ">> sudo dnf install fedrq"
    exit -1
fi

if ! command -v fedpkg &> /dev/null
then
    echo ">> fedpkg not found! Exiting."
    exit -1
fi

impact_check () {
    echo ">> Checking update impact using fedrq for ${branch}"
    echo ">> The following packages will be affected. Please ensure that they do not break as a result of this update:"
    fedrq whatrequires-src -b "${branch}" -F breakdown -X "${PACKAGE_NAME}"
}

run () {
    if [ "" == "${branches}" ]
    then
        echo ">> No branches suplied. Exiting"
        usage
        exit -1
    fi

    echo ">> Updating repo and rebasing"
    git checkout rawhide
    git pull --rebase

    for branch in $branches
    do
        echo ">> Working on branch: ${branch}"

        if [ "No" == "${IMPACT_CHECKED}" ]
then
            impact_check
            echo ">> Do you wish to proceed with the update for ${branch}?"
            select yn in "Yes" "No"; do
                case $yn in
                    Yes ) break;;
                    No ) echo ">> Not proceeding with update for ${branch}"; continue 2;;
                esac
            done
        else
            echo ">> SKIPPING IMPACT CHECK"
            echo ">> Please ensure that you have ALREADY checked the impact of this package on dependencies"
        fi

        if  [ "meh" == "${UPDATE_NOTE}" ]
        then
            echo ">> Merging and building"
            fedpkg switch-branch "$branch" && git pull && git merge rawhide && git push && fedpkg build || exit -1
        else
            echo ">> Merging, building, creating update"
            fedpkg switch-branch "$branch" && git pull && git merge rawhide && git push && fedpkg build && fedpkg update --type "${TYPE}" --notes "${UPDATE_NOTE}" || exit -1
    fi
    done
}

usage () {
    echo "Usage: "
    echo "$0 [-utI][-i] <branches to sync with rawhide>"
    echo
    echo "Options:"
    echo "-i only run impact check"
    echo "-u <update note>"
    echo "-t <update type>: see 'fedpkg update -h' for valid options"
    echo "-I skip impact check (because you've done this already)"
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
while getopts "Iiu:t:h" OPTION
do
    case $OPTION in
        u)
            UPDATE_NOTE="$OPTARG"
            ;;
        t)
            TYPE="$OPTARG"
            ;;
        i)
            IMPACT_CHECK="Yes"
            ;;
        I)
            IMPACT_CHECKED="Yes"
            ;;
        h)
            usage
            exit 0
            ;;
    esac
done

shift $(($OPTIND - 1))
branches="$@"
if [ "Yes" == "${IMPACT_CHECK}" ]
then
    for branch in $branches
    do
        impact_check
    done
    exit 0
fi
run
