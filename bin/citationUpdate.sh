#!/bin/bash

# This script just combines all my bibtex files into a global citation file

rm -f ~/Documents/readables/citationsGlobal.bib
cd /home/ankur/Documents/readables/reference/research_papers

find . -name "citation.bib" -exec dos2unix '{}' \;
find . -name "scholar.bib" -exec dos2unix '{}' \;
find . -name "citation.bib" -exec cat '{}' >> ~/Documents/readables/citationsGlobal.bib \;
find . -name "scholar.bib" -exec cat '{}' >> ~/Documents/readables/citationsGlobal.bib \;
