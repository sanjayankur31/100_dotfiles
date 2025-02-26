#!/bin/bash

# Copyright 2025 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : bin/fedpkg-new-crate.sh
#
#

set -e

REMOTE_URL="git@github.com:sanjayankur31/"
CREATE_REPO="no"
MOCKBUILD="no"

package_crate ()
{

    if ["yes" == "$CREATE_REPO" ]
    then
        fedpkg-new-package -n "${packagename}"
    fi

    rust2rpm -I "$cratename" && spectool -g "${packagename}.spec" && git add "${packagename}.spec" && git commit -m "feat: init" && git push -u origin main 

    if ["yes" == "$MOCKBUILD" ]
    then
        fedpkg --release rawhide mockbuild
    fi
    popd
}

usage () {
    echo "$0: <options>"
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
            cratename="$OPTARG"
            packagename="rust-$cratename"
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
