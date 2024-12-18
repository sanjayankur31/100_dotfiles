#!/bin/bash

set -e

# Copyright 2024 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File : fedpkg-rebuild-deps.sh
#
# Run builds for a specified list of packages in a linear order, ensuring that
# the previous build was in the side tag before proceeding.
#
# To be run in a folder containing the various SCM folders.

PACKAGE_LIST_FILE="packages.txt"
FEDORA_BRANCH="rawhide"
SIDE_TAG=""
CHANGELOG_ENTRY=""
DRY_RUN="NO"

dobuilds () {
    while read pkg ; do
        if ! [ -d "$pkg" ]
        then
            echo "> Checking out ${pkg}"
            fedpkg co "$pkg"
        fi
        echo "> Rebuilding ${pkg} in side tag ${SIDE_TAG} for branch ${FEDORA_BRANCH}"

        pushd "$pkg"
        git clean -dfx && fedpkg switch-branch "${FEDORA_BRANCH}" && git reset HEAD --hard && git pull --rebase

        if grep "autochangelog" *.spec
        then
            echo "> rpmautospec used"
            if [ "NO" == "$DRY_RUN" ]
            then
                git commit --allow-empty -m "$CHANGELOG_ENTRY"
            else
                echo "> DRY RUN: did not add empty commit for changelog"
            fi
        else
            if [ "NO" == "$DRY_RUN" ]
            then
                rpmdev-bumpspec -c "${CHANGELOG_ENTRY}"
            else
                echo "> DRY RUN: did not add new changelog entry"
            fi
        fi
        if [ "NO" == "$DRY_RUN" ]
        then
            fedpkg build --target="${SIDE_TAG}"
            koji wait-repo --request "${SIDE_TAG}"
        else
            echo "> DRY RUN: did not run build"
        fi
        popd
    done < "${PACKAGE_LIST_FILE}"
}

usage () {
    echo "$0: utility script for building packages in order in a side tag "
    echo
    echo "Build packages in order in the provided side tag with the provided changelog entry"
    echo
    echo "Note that the builds happen in linear order, given in the file pointed to by -l."
    echo "Only when a build completes, and a new repo is generated does the next build proceed."
    echo "This is to ensure that a build has appeared in the repo before the next build is run, and is currently the only way to ensure this."
    echo
    echo "Usage:"
    echo
    echo "-h: print help and exit"
    echo "-s <side tag>"
    echo "-l <name of package list file to read from>"
    echo "   <default: packages.txt>"
    echo "-f <branch of SCM to build>"
    echo "   <default: rawhide>"
    echo "-c <changelog entry>"
    echo "-d dry run: check out repositories but do not add a changelog and run the builds"
}

if [ $# -lt 1 ]
then
    usage
    exit -1
fi

# parse options
# https://stackoverflow.com/questions/11742996/is-mixing-getopts-with-positional-parameters-possible
while getopts "c:s:f:l:ndh" OPTION
do
    case $OPTION in
        s)
            SIDE_TAG="$OPTARG"
            ;;
        c)
            CHANGELOG_ENTRY="$OPTARG"
            ;;
        f)
            FEDORA_BRANCH="$OPTARG"
            ;;
        l)
            PACKAGE_LIST_FILE="$OPTARG"
            ;;
        d)
            DRY_RUN="YES"
            echo "> Dry run enabled"
            echo "> Will checkout repositories but not add changelogs and run builds"
            ;;
        h)
            usage
            exit 0
            ;;
    esac
done

if [ -z "$CHANGELOG_ENTRY" ]
then
    echo "> A changelog entry is required."
    echo "> Please specify one with the -c flag."
    exit -1
fi
if [ -z "$SIDE_TAG" ]
then
    echo "> A side tag is required."
    echo "> Please specify one with the -s flag."
    exit -1
fi

if ! [ -f "$PACKAGE_LIST_FILE" ]
then
    echo "> Could not find a list of pacakges at ${PACKAGE_LIST_FILE}."
    echo "> Please check that it exists or use the -l flag to specify it."
    exit -1
fi

dobuilds
