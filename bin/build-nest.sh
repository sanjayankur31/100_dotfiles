#!/bin/bash

# Copyright 2015 Ankur Sinha 
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
# File : 
#
if [[ "$HOSTNAME" = "uhhpc.herts.ac.uk" ]] || [[ $HOSTNAME =~ headnode* ]] || [[ $HOSTNAME =~ ^(node)[0-9]+ ]] ; then
    module load mvapich2
    export CFLAGS="-O2"
    export CXXFLAGS="-O2"
    INSTALL_PATH="/home/asinha/installed-software/nest-mvapich2/"
    cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PATH -Dwith-python:STRING=3 -Dwith-mpi:BOOL=ON  .
else
    export CFLAGS="-ggdb"
    export CXXFLAGS="-ggdb"
    INSTALL_PATH="/opt/nest/"
    cmake -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL_PATH -Dwith-python:STRING=3 -Dwith-mpi:BOOL=ON -Dwith-debug:BOOL=ON -Dwith-optimize:BOOL=OFF .
fi
echo "Now run:"
echo "make -j24; make install; source /$INSTALL_PATH/bin/nest_vars.sh"
