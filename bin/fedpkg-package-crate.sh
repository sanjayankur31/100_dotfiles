#!/bin/bash

# Copyright 2025 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : bin/fedpkg-package-crate.sh
#
# Set up new folder/repo and try to create a new spec for a crate using rust2rpm

set -e

CREATE_REPO="no"
MOCKBUILD="no"

if ! command -v rust2rpm &> /dev/null
then
    echo ">> rust2rpm not found. Please install rust2rpm:"
    echo ">> sudo dnf install rust2rpm"
    exit -1
fi

if ! command -v fedpkg &> /dev/null
then
    echo ">> fedpkg not found. Please install fedpkg:"
    echo ">> sudo dnf install fedpkg"
    exit -1
fi

if ! command -v fedpkg-new-package.sh &> /dev/null
then
    echo ">> fedpkg-new-package.sh not found. Please download it from the same repo you got this script from."
    exit -1
fi

package_crate ()
{

    if [ "yes" == "$CREATE_REPO" ]
    then
        fedpkg-new-package.sh -n "${PACKAGENAME}"
    fi
    pushd "${PACKAGENAME}"
    rust2rpm -I "$CRATENAME" && spectool -g "${PACKAGENAME}.spec" && git add "${PACKAGENAME}.spec" && git commit -m "feat: init" && git push -u origin main 

    if [ "yes" == "$MOCKBUILD" ]
    then
        fedpkg --release rawhide mockbuild
    fi
    popd
}

usage () {
    echo
    echo "$(basename $0): -n <crate> [-cmh]"
    echo
    echo "Init a new rust crate based package"
    echo
    echo "Usage:"
    echo
    echo "-h: print help and exit"
    echo "-n <crate name>"
    echo "   name of rust crate"
    echo "-c: Create folder and GitHub remote"
    echo "-m: Try a mockbuild after initial import"
}

if [ $# -lt 1 ]
then
    usage
    exit -1
fi

while getopts "n:cmh" OPTION
do
    case $OPTION in
        n)
            CRATENAME="$OPTARG"
            PACKAGENAME="rust-$CRATENAME"
            ;;
        c)
            CREATE_REPO="yes"
            ;;
        m)
            MOCKBUILD="yes"
            ;;
        h)
            usage
            exit 0
            ;;
    esac
done

package_crate
