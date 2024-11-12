#!/bin/bash

# Copyright 2024 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : 

YOUR_USER="ankursinha"
PACKAGE="$(basename $(pwd))"

echo "Adding packit remote for ${PACKAGE}"


git remote add packit ssh://"${YOUR_USER}"@pkgs.fedoraproject.org/forks/packit/rpms/"${PACKAGE}".git
git fetch packit
