#!/usr/bin/env sh
# From http://terminalmage.net/2011/10/12/printing-to-pdf-in-mutt.html
INPUT="$1" PDIR="$HOME/Desktop/mutt_print"

# check to make sure that enscript and ps2pdf are both installed
if ! command -v enscript >/dev/null || ! command -v ps2pdf >/dev/null; then
    echo "ERROR: both enscript and ps2pdf must be installed" 1>&2
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

tmpfile="`mktemp $PDIR/mutt_XXXXXXXX.pdf`"
enscript --font=Courier10 $INPUT -G -Email -p - 2>/dev/null | ps2pdf - $tmpfile
#enscript --font=Courier10 $INPUT -G -Email -p - 2>/dev/null | ps2pdf - $tmpfile
gnome-open $tmpfile >/dev/null 2>&1 &
