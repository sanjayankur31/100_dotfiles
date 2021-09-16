#!/bin/bash

# Copyright 2021 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File :  make mount points for docker: needed after each reboot
#
# From: https://github.com/docker/for-linux/issues/219#issuecomment-375160449
# needs to be run as root/sudo

mkdir /sys/fs/cgroup/systemd
mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
