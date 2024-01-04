#!/bin/bash

# Copyright 2023 Ankur Sinha
# Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com> 
# File : pip-upgrade-all.sh
#
# Upgrade all installed packages.
# Taken from https://stackoverflow.com/a/3452888/375067
#

pip --disable-pip-version-check list --outdated --format=json | python -c "import json, sys; print('\n'.join([x['name'] for x in json.load(sys.stdin)]))" | xargs -n1 pip install -U

