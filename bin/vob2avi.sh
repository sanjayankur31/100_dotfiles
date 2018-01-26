#!/bin/bash

# Copyright 2010 Ankur Sinha 
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
mencoder \
-vf harddup \
-vf-add smartblur=.6:-.5:0,unsharp=l5x5:.8:c5x5:.4 \
-xvidencopts fixed_quant=4:profile=dxnhtntsc \
-lameopts cbr:br=128:aq=0:vol=1 \
-oac mp3lame \
-ovc xvid \
$1 -o $2

exit
