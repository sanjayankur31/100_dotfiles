#!/bin/bash

set -e

# Copyright 2024 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File : fedpkg-rebuild-deps.sh
#
# Run builds for a specified list of packages in a linear order, ensuring that
# the previous build was in the side tag before proceeding. Groups can be
# specified using `:`. See `fedpkg chain-build --help` for more information.
#
# To be run in a folder containing the various SCM folders.

PACKAGE_LIST_FILE="packages.txt"
FEDORA_BRANCH="rawhide"
SIDE_TAG=""
CHANGELOG_ENTRY=""
DRY_RUN="NO"
SPECBUMP_USERSTRING="Ankur Sinha <ankursinha AT fedoraproject DOT org>"

# fedpkg chain-build needs to be called from the package dir
LAST_PACKAGE=""

dobuilds () {
    declare -a ALL_PACKAGES
    while read pkg ; do
        if ! [ ":" == "$pkg" ]
        then
            if ! [ -d "$pkg" ]
            then
                echo "> Checking out ${pkg}"
                fedpkg co "$pkg"
            fi
            echo "> Rebuilding ${pkg} in side tag ${SIDE_TAG} for branch ${FEDORA_BRANCH}"

            pushd "$pkg"
            git clean -dfx && fedpkg switch-branch "${FEDORA_BRANCH}" && git reset HEAD --hard && git pull --rebase

            if grep "autochangelog" "${pkg}.spec"
            then
                echo "> rpmautospec used"
                if [ "NO" == "$DRY_RUN" ]
                then
                    git commit --allow-empty -m "$CHANGELOG_ENTRY"
                    git push
                else
                    echo "> DRY RUN: did not add empty commit for changelog"
                fi
            else
                if [ "NO" == "$DRY_RUN" ]
                then
                    rpmdev-bumpspec -c "${CHANGELOG_ENTRY}"  "${pkg}.spec"
                    git add "${pkg}.spec"
                    git commit -m "$CHANGELOG_ENTRY"
                    git push
                else
                    echo "> DRY RUN: did not add new changelog entry"
                fi
            fi
            popd
            LAST_PACKAGE="$pkg"
        else
            echo "> Group boundary encountered"
        fi
        ALL_PACKAGES+=("$pkg")
    done < "${PACKAGE_LIST_FILE}"

    # drop the last package from the list, we'll enter this folder to run the
    # fedpkg-chain command
    unset 'ALL_PACKAGES[-1]'
    pushd ${LAST_PACKAGE}
    if [ "NO" == "$DRY_RUN" ]
    then
        echo "> Running chain build in ${LAST_PACKAGE} directory"
        IFS=" " echo "> Command: fedpkg chain-build --target=${SIDE_TAG} ${ALL_PACKAGES[@]}"
        IFS=" " fedpkg chain-build --target="${SIDE_TAG}" ${ALL_PACKAGES[@]}
    else
        echo "> DRY RUN: did not run chain build in ${LAST_PACKAGE} directory"
        IFS=" " echo "> Command: fedpkg chain-build --target=${SIDE_TAG} ${ALL_PACKAGES[@]}"
    fi
    popd
}

usage () {
    echo "$0: <options>"
    echo
    echo "Build packages in order in the provided side tag with the provided changelog entry"
    echo
    echo "Note that the builds happen in linear order, given in the file pointed to by -l."
    echo "Run builds for a specified list of packages in a linear order, ensuring that"
    echo "the previous build was in the side tag before proceeding. Groups can be"
    echo "specified using ':'. See 'fedpkg chain-build --help' for more information."
    echo ""
    echo "To be run in a folder containing the various SCM folders."
    echo
    echo "Usage:"
    echo
    echo "-h: print help and exit"
    echo "-s <side tag>"
    echo "-l <name of package list file to read from: the last line must be the final package>"
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
