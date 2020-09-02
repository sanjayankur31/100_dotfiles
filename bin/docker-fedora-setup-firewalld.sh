#!/bin/bash

# Copyright 2020 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : docker-fedora-setup-firewall.sh
# From https://github.com/moby/moby/issues/16137#issuecomment-271615192
#
# Note that the fedora moby engine package includes the firewall zone rule
# https://src.fedoraproject.org/rpms/moby-engine/blob/master/f/docker-zone.xml
# but the docker-ce package does not

# This needs to be run as sudo

nmcli connection modify docker0 connection.zone trusted
systemctl stop NetworkManager.service
firewall-cmd --permanent --zone=trusted --change-interface=docker0
systemctl start NetworkManager.service
nmcli connection modify docker0 connection.zone trusted
systemctl restart docker.service
