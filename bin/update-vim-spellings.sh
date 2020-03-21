#!/bin/bash

# Copyright 2020 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : update-vim-spellings.sh
#
# Removes any merge conflict markers, sorts the words, removes duplicates.

SPELLFILE="en.utf-8.add"
SPELLDIR="$HOME"/.vim/spell

pushd "$SPELLDIR" || exit -1
    sed -i -e '/^=+$/ d' -e '/^>+$/ d' -e '/^<+$/ d' "$SPELLFILE"
    sort -h "$SPELLFILE" | uniq > "$SPELLFILE.new"
    mv "$SPELLFILE.new" "$SPELLFILE" -v
popd
