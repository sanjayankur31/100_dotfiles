#!/bin/bash

# Copyright 2026 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File : git-update-repo.sh

DEFAULT_BRANCHES="main:master:development:experimental"
DEFAULT_DIRECTORIES=""


update_git_project () {
    local stash_res
    local current_branch

    current_branch=$(git branch --show-current) || { echo "** Could not get current branch. Skipping this directory **" ; return ; }

    stash_msg="auto-update-stash-$(date +%Y%m%d-%H%M)"
    stash_res=$(git stash push -a -m "$stash_msg")

    git pull

    IFS=':' read -ra BRANCHES <<< "$DEFAULT_BRANCHES"
    for abranch in "${BRANCHES[@]}"
    do
        # skip current branch: already pulled
        if [[ "$abranch" == "$current_branch" ]]
        then
            continue
        fi

        echo
        if git show-ref --verify --quiet "refs/heads/$abranch"
        then
            echo "** Attempting to update branch: $abranch **"
            if ! { git checkout "$abranch" && git pull ; }
            then
                echo "!! Conflict or error when updating $abranch. Skipping. !!"
                git merge --abort 2>/dev/null
            fi
        else
            echo "** Could not find branch: $abranch. Continuing to next. **"
        fi
    done
    echo

    echo "** Returning to $current_branch **"
    git checkout "$current_branch"

    # Only pop if we actually stashed something
    if [[ "$stash_res" != "No local changes to save" ]]; then
        git stash pop --quiet
    fi

    git status -s
    echo
    git stash list
    echo
}

update_git_projects () {
    IFS=':' read -ra DIRECTORIES <<< "$DEFAULT_DIRECTORIES"
    for adir in "${DIRECTORIES[@]}"
    do
        pushd "$adir" > /dev/null || { echo "Could not enter $adir. Please check. Trying next" ; continue ; }
        echo "** Updating $adir **"
        update_git_project
        popd > /dev/null || true
    done
}

usage () {
    echo
    echo "$(basename $0): [-dbah]"
    echo
    echo "Update multiple branches in multiple git repository folders"
    echo
    echo "Usage:"
    echo
    echo "Without any options: updates current folder"
    echo
    echo "-a: update all git directories in current directory"
    echo "    uses the output of \"ls -d */\""
    echo "-b <branches>"
    echo "    colon separated list of branches to update"
    echo "    default value, if unspecified: ${DEFAULT_BRANCHES}"
    echo "-d <directories>"
    echo "    colon separated list of git directories to update"
    echo "    eg: \"a:b:c\""
    echo "-h: print help and exit"

}


while getopts "ab:d:h" OPTION
do
    case $OPTION in
        a)
            DEFAULT_DIRECTORIES="$(find . -maxdepth 1 -name '[!.]*' -type d -printf '%P:')"
            ;;
        b)
            DEFAULT_BRANCHES="$OPTARG"
            ;;
        d)
            DEFAULT_DIRECTORIES="$OPTARG"
            ;;
        h)
            usage
            exit 1
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done

# If no directories defined and no flags used, use current dir
if [[ -z "$DEFAULT_DIRECTORIES" ]]; then
    update_git_project
else
    update_git_projects
fi
