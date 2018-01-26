#!/usr/bin/bash
# From https://www.nixternal.com/mark-e-mails-in-mutt-as-tasks-in-taskwarrior/
task add project:email due:1d E-mail: "$(sed -n '/^Subject: /{s///p;q}')"
