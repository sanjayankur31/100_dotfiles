#!/bin/bash

# Copyright 2025 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : bin/pass2md.sh
#
# export all pass entries to markdown file for printing/safekeeping
#


set -e
shopt -s nullglob globstar

PASSWORD_STORE_DIR="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
PASSWORD_MD_FILE="$HOME/allpasswords.md"
echo ">> password store dir is: ${PASSWORD_STORE_DIR}"

echo "# All passwords" > "$PASSWORD_MD_FILE"
echo "Exported on $(date)" >> "$PASSWORD_MD_FILE"
echo >> "$PASSWORD_MD_FILE"
echo >> "$PASSWORD_MD_FILE"
echo >> "$PASSWORD_MD_FILE"

pushd "${PASSWORD_STORE_DIR}"
    for FILE in **/*.gpg
    do
        entry="${FILE%.*}"
        echo ">> Processing: ${entry}"
        echo "# ${entry}" >> "$PASSWORD_MD_FILE"
        echo >> "$PASSWORD_MD_FILE"
        pass ${entry}  >> "$PASSWORD_MD_FILE"
        echo >> "$PASSWORD_MD_FILE"
        echo >> "$PASSWORD_MD_FILE"
done
popd
