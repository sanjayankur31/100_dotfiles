#!/bin/bash

# Copyright 2020 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : update-vim-spellings.sh
#
# Removes any merge conflict markers, sorts the words, removes duplicates.

set -e

OURLANG="en.utf-8"
SPELLFILE="${OURLANG}.add"
SPELLDIR="$HOME"/.vim/spell

pushd "$SPELLDIR" || exit -1
    # make sure we have everything, including syncthing conflict files
    sort -h "${OURLANG}"*.add "${SPELLFILE}"*backup | uniq > "${SPELLFILE}.new"

    # no longer needed, not under git
    # sed -i -e '/^=+$/ d' -e '/^>+$/ d' -e '/^<+$/ d' "$SPELLFILE"

    cp "${SPELLFILE}.new" "${SPELLFILE}.backup" -v
    mv "$SPELLFILE.new" "$SPELLFILE" -v

    # remove sync conflict files
    rm *.sync-conflict* -fv
popd
