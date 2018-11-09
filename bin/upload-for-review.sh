#!/bin/sh

PACKAGE=""
DESTDIR=""

upload ()
{
    DESTDIR="./public_html/$PACKAGE/"
    echo "Uploading to fedorapeople.org:$DESTDIR"
    rsync -avPh ~/rpmbuild/SPECS/"$PACKAGE.spec" fedorapeople.org:$DESTDIR
    rsync -avPh ~/rpmbuild/SRPMS/"$PACKAGE"*src.rpm fedorapeople.org:$DESTDIR
}

clean ()
{
    DESTDIR="./public_html/$PACKAGE/"
    echo "Cleaning fedorapeople.org:$DESTDIR"
    ssh fedorapeople.org rm -fvr $DESTDIR

}

usage ()
{
    echo "$0"
    echo 
    echo "Upload spec and srpms to fedorapeople.org for review"
    echo "OPTIONS"
    echo '-p PACKAGENAME: upload to fedorapeople.org'
    echo '-r PACKAGENAME: clean before uploading to fedorapeople.org'
}

# check for options
if [ "$#" -ne 2 ]; then
    usage
    exit 0
fi

# parse options
while getopts "r:p:" OPTION
do
    case $OPTION in
        p)
            PACKAGE=$OPTARG
            upload
            exit 0
            ;;
        r)
            PACKAGE=$OPTARG
            clean
            upload
            exit 0
            ;;
        ?)
            echo "Nothing to do."
            exit 1
            ;;
    esac
done
