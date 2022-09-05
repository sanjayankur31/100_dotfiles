#!/bin/bash

# Copyright 2022 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File : fedora-run-copr-builds.sh
#
# Run copr builds for a specified list of packages. Useful when one wants to
# test rebuilding a bunch of dependencies when updating packages
#
# To be run in a folder containing the various SCM folders.
# Update variable names as required

PACKAGE_LIST_FILE="packages.txt"
FEDORA_BRANCH="rawhide"
COPR_PROJECT=""
# uncomment to wait for each build, for example a chain build where each
# package must wait for the previous one to build
# NOWAIT="yep"

while read pkg ; do
    echo "Rebuilding ${pkg} in COPR project ${COPR_PROJECT} for branch ${FEDORA_BRANCH}"
    pushd "$pkg" && git clean -dfx && git pull --rebase && git checkout "${FEDORA_BRANCH}" && fedpkg srpm && copr-cli build  "${NOWAIT:+ --nowait}" "${COPR_PROJECT}" *.src.rpm && popd
done < "${PACKAGE_LIST_FILE}"
