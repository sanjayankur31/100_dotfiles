#!/usr/bin/env sh
# From http://terminalmage.net/2011/10/12/printing-to-pdf-in-mutt.html
INPUT="$1" PDIR="$HOME/Desktop/mutt_print"

# check to make sure that enscript and ps2pdf are both installed
if ! command -v muttprint >/dev/null || ! command -v ps2pdf >/dev/null; then
    echo "ERROR: both muttprint and ps2pdf must be installed" 1>&2
    exit 1
fi

# create temp dir if it does not exist
if [ ! -d "$PDIR" ]; then
    mkdir -p "$PDIR" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Unable to make directory '$PDIR'" 1>&2
        exit 2
    fi
fi

timestamp=$(date +%Y%m%d%H%M)
tmpfile="$(mktemp $PDIR/$timestamp-email-XXX.pdf)"
muttprint | ps2pdf - $tmpfile

#enscript --font=Courier10 $INPUT -G -Email -p - 2>/dev/null | ps2pdf - $tmpfile
#enscript --font=Courier10 $INPUT -G -Email -p - 2>/dev/null | ps2pdf - $tmpfile

if ! command -v zathura >/dev/null ; then
    echo "Zathura not found. File saved as $tmpfile"
    exit 3
else
    zathura $tmpfile && rm -f $tmpfile
fi
