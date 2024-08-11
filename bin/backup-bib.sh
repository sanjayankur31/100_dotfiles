#!/bin/bash

# Copyright 2024 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : backup bibliography file
#

timestamp="$(date +%Y%m%d%H%M)"

pushd ~/Documents/01_Readables/00_research_papers/bibliography && cp -av masterbib.bib "${timestamp}-masterbib.bib" && popd
