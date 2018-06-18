#!/usr/bin/bash
# From https://www.nixternal.com/mark-e-mails-in-mutt-as-tasks-in-taskwarrior/
sender="$(sed -n '/^From: /{s///p;q}')"
subject="$(sed -n '/^Subject: /{s///p;q}')"
task add project:email due:1d "$sender: $subject"
