#!/bin/bash

# Copyright 2022 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : bin/fedpkg-sync-build-all-branches.sh
#
# Just a shortcut so I don't have to write the for loop each time myself.

branches="$@"

echo "Updating repo and rebasing"
git pull --rebase

for branch in $branches
do
    echo "Working on branch: ${branch}"
    fedpkg switch-branch "$branch" && git pull && git merge rawhide && git push && fedpkg build
done
