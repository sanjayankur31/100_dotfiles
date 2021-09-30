#!/bin/bash

# Copyright 2021 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : 
#
echo "Checking IO scheduler"
cat /sys/block/*/queue/scheduler

echo "I hope you ran me using sudo"
echo mq-deadline | sudo tee /sys/block/*/queue/scheduler

echo "Checking IO scheduler changed"
cat /sys/block/*/queue/scheduler
