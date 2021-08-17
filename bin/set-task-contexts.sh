#!/bin/bash

# Copyright 2020 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
# File : set-task-contexts.sh
#

# Set contexts for task at different times
# Needs to be run once at the start of the day

echo "task context work" | at 0930
echo "task context none"  | at 1700
