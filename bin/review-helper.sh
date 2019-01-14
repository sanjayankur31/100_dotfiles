#!/bin/sh
# A helper script for various review related tasks

PACKAGE=""
DESTDIR=""
KOJI_TASK=""


check_package ()
{
    if [[ -z "$PACKAGE" ]];
    then
        echo "A package name is necessary for use with this option. Please use -p"
        exit -1
    fi

}
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
    echo "Downloading $KOJI_TASK in $HOME/rpmbuild/RPMS/$PACKAGE"
    rm -fvr -- "$HOME/rpmbuild/RPMS/$PACKAGE"
    mkdir -pv "$HOME/rpmbuild/RPMS/$PACKAGE"
    pushd "$HOME/rpmbuild/RPMS/$PACKAGE" || exit -1
        koji download-task $KOJI_TASK
    popd
}

copyovermockresults ()
{
    echo "Copying rpms from mock result to $HOME/rpmbuild/RPMS/$PACKAGE"
    rm -fvr -- "$HOME/rpmbuild/RPMS/$PACKAGE"
    mkdir -pv "$HOME/rpmbuild/RPMS/$PACKAGE"
    pushd "$HOME/rpmbuild/RPMS/$PACKAGE" || exit -1
        cp -v /var/lib/mock/fedora-rawhide-x86_64/result/*.rpm .
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
    echo "Running rpmlint on $PACKAGE rpms in $HOME/rpmbuild/RPMS/$PACKAGE"
    echo
    rpmlint "$HOME/rpmbuild/RPMS/$PACKAGE/"*".rpm"
    echo
}

list_reqs_provides ()
{
    echo "Listing requires and provies of packages in $HOME/rpmbuild/RPMS/$PACKAGE"
    pushd "$HOME/rpmbuild/RPMS/$PACKAGE" || exit -1
        for i in *rpm; do
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
    echo "$0 -p packagename -l -L -r -u -d task-id"
    echo

    cat << EOF
OPTIONS
-p PACKAGE: Required
-d <task id>: download rpms from koji task
-l rpmlint spec and srpm
-L run rpmlint on spec/srpm/rpms
-r list requires and provides of rpms
-u clean and upload to fedorapeople
-m copy mock results
EOF
}

# parse options
while getopts "rmLuld:p:" OPTION
do
    case $OPTION in
        p)
            PACKAGE=$OPTARG
            ;;
        m)
            copyovermockresults
            ;;
        d)
            KOJI_TASK=$OPTARG
            downloadrpms
            ;;
        l)
            check_package
            rpmlint_spec_srpm
            ;;
        L)
            check_package
            rpmlint_spec_srpm
            rpmlint_rpms
            ;;
        r)
            check_package
            list_reqs_provides
            ;;
        u)
            check_package
            clean
            upload
            ;;
        ?)
            echo "Nothing to do."
            usage
            exit 1
            ;;
    esac
done
