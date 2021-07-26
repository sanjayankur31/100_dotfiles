#!/bin/bash

# Copyright 2020 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# File : updateplanet.sh
#

export SSH_AUTH_SOCK=/home/asinha/.byobu/.ssh-agent
REPODIR="/home/asinha/Documents/02_Code/00_mine/NeuroFedora/"

echo "Updating planets"
pushd "$REPODIR"planet-neuroscience
    ./update.sh
popd
echo "Updated neuroscience"

pushd "$REPODIR"planet-neuroscientists
    ./update.sh
popd
echo "Updated neuroscientists"
