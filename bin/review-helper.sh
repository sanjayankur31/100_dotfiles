#!/bin/sh
# A helper script for various review related tasks

PACKAGE=""
DESTDIR=""
KOJI_TASK=""
MOCKREL="rawhide"
MOCKARCH="x86_64"


check_package ()
{
    if [[ -z "$PACKAGE" ]];
    then
        echo "A package name is necessary for use with this option. Please use -p"
        exit 2
    fi

}
upload ()
{
    DESTDIR="./public_html/$PACKAGE/"
    echo "Uploading to fedorapeople.org:$DESTDIR"
    rsync -avPh "$PACKAGE.spec" fedorapeople.org:$DESTDIR
    rsync -avPh "$PACKAGE"*src.rpm fedorapeople.org:$DESTDIR
}

clean ()
{
    DESTDIR="./public_html/$PACKAGE/"
    echo "Cleaning fedorapeople.org:$DESTDIR"
    ssh fedorapeople.org rm -fvr $DESTDIR

}

downloadrpms ()
{
    echo "Downloading $KOJI_TASK to RPMS/"
    rm -fvr -- "RPMS"
    mkdir -pv "RPMS"
    pushd "RPMS" || exit 3
        koji download-task $KOJI_TASK
    popd || exit 4
}

copyovermockresults ()
{
    echo "Copying rpms from mock result to RPMS/"
    rm -fvr -- "RPMS"
    mkdir -pv "RPMS"
    pushd "RPMS" || exit 3
        cp -v /var/lib/mock/fedora-$MOCKREL-$MOCKARCH/result/*.rpm .
    popd || exit 4
}

rpmlint_spec_srpm()
{
    echo "Running rpmlint on $PACKAGE spec and srpm"
    echo
    rpmlint "$PACKAGE.spec" "$PACKAGE"*".src.rpm"
    echo
}

rpmlint_rpms ()
{
    echo "Running rpmlint on $PACKAGE rpms in RPMS/"
    echo
    rpmlint "RPMS/"*".rpm"
    echo
}

list_reqs_provides ()
{
    echo "Listing requires and provies of packages in RPMS"

    result_dir="results_${PACKAGE}"
    newest_version=""
    rpm_dir=""
    overall_dir=""
    if [ -d "${result_dir}" ]
    then
        newest_version=$(ls -v ${result_dir}/ | tail -1)
        rpm_dir="$(ls -v $result_dir/$newest_version/ | tail -1)"
        overall_dir="$result_dir/$newest_version/$rpm_dir"
    elif [ -d "RPMS" ]
    then
        overall_dir="$result_dir/$newest_version/$rpm_dir"
    else
        echo "Could not figure out what directory rpms are in. Exiting"
    fi

    echo "Processing RPMs in $overall_dir"
    pushd "$overall_dir" 2>&1 > /dev/null || exit 3
        for i in *rpm; do
            echo "== $i =="
            echo "Provides:"
            rpm -qp --provides --recommends "$i" | sed "/rpmlib.*/d"
            echo  ; echo "Requires/Recommends:"
            rpm -qp --requires --recommends "$i" | sed "/rpmlib.*/d"
            echo
        done
    popd || exit 4
}

usage ()
{
    echo "$0 -p packagename -l | -L | -r | -u | -d task-id | [-f -a] -m"
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
-f used before -m: fedora release being used over for mock builds (default: rawhide)
-a used before -m: fedora arch being used over for mock builds (default: x86_64)
EOF
}

# parse options
while getopts "rmLuld:p:f:a:" OPTION
do
    case $OPTION in
        p)
            PACKAGE=$OPTARG
            ;;
        f)
            MOCKREL=$OPTARG
            ;;
        a)
            MOCKARCH=$OPTARG
            ;;
        m)
            check_package
            copyovermockresults
            ;;
        d)
            KOJI_TASK=$OPTARG
            check_package
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
