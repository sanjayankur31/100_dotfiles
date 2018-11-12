#!/bin/sh
# A helper script for various review related tasks

PACKAGE=""
DESTDIR=""
KOJI_TASK=""


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

downloadrpms ()
{
    echo "Downloading $KOJI_TASK in $HOME/rpmbuild/RPMS/"
    pushd "$HOME/rpmbuild/RPMS/"
        koji download-task $KOJI_TASK
    popd
}

rpmlint_spec_srpm()
{
    echo "Running rpmlint on $PACKAGE spec and srpm"
    echo
    rpmlint "$HOME/rpmbuild/SPECS/$PACKAGE.spec" "$HOME/rpmbuild/SRPMS/$PACKAGE"*".src.rpm"
    echo
}

rpmlint_rpms ()
{
    echo "Running rpmlint on $PACKAGE rpms in $HOME/rpmbuild/RPMS/"
    echo
    rpmlint "$HOME/rpmbuild/RPMS/$PACKAGE"*".rpm"
    echo
}

list_reqs_provides ()
{
    echo "Listing requires and provies of packages in $HOME/rpmbuild/RPMS/"
    pushd "$HOME/rpmbuild/RPMS/"
        for i in "$PACKAGE"*rpm; do
            echo "== $i =="
            echo "Provides:"
            rpm -qp --provides $i | sed "/rpmlib.*/d"
            echo  ; echo "Requires:"
            rpm -qp --requires $i | sed "/rpmlib.*/d"
            echo
        done
    popd
}

usage ()
{
    echo "$0"
    echo

    cat << EOF
OPTIONS
-d <task id>: download rpms from koji task
-l PACKAGE: rpmlint spec and srpm
-L PACKAGE: run rpmlint on spec/srpm/rpms in pwd
-r list requires and provides of rpms in current directory
-u PACKAGE: clean and upload to fedorapeople
EOF
}

# check for options
if [ "$#" -ne 2 ]; then
    usage
    exit 0
fi

# parse options
while getopts "rL:u:l:d:" OPTION
do
    case $OPTION in
        d)
            KOJI_TASK=$OPTARG
            downloadrpms
            exit 0
            ;;
        l)
            PACKAGE=$OPTARG
            rpmlint_spec_srpm
            exit 0
            ;;
        L)
            PACKAGE=$OPTARG
            rpmlint_spec_srpm
            rpmlint_rpms
            exit 0
            ;;
        r)
            PACKAGE=$OPTARG
            list_reqs_provides
            exit 0
            ;;
        u)
            PACKAGE=$OPTARG
            clean
            upload
            exit 0
            ;;
        ?)
            echo "Nothing to do."
            usage
            exit 1
            ;;
    esac
done
