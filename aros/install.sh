#!/bin/sh
# Install the OpenMW build products into the AROS game drawer.
#   $1 = CMake build directory, $2 = destination directory,
#   $3 = strip command (optional, may carry options; the AROS build strips
#        release binaries)
set -e
BUILDDIR="$1"
DESTDIR="$2"
STRIP="$3"
mkdir -p "$DESTDIR"
if [ -n "$STRIP" ]; then
    $STRIP -o "$DESTDIR/OpenMW" "$BUILDDIR/openmw"
else
    cp "$BUILDDIR/openmw" "$DESTDIR/OpenMW"
fi
for f in openmw.cfg defaults.bin gamecontrollerdb.txt; do
    cp "$BUILDDIR/$f" "$DESTDIR/$f"
done
rm -rf "$DESTDIR/resources"
cp -R "$BUILDDIR/resources" "$DESTDIR/resources"

# On AROS the game is self contained in its drawer: when the Morrowind data
# files have been placed in "data/" next to the executable, register them in
# the local openmw.cfg (upstream leaves this to the Qt launcher, which is not
# built here).  Expansions are added when present.
if [ -f "$DESTDIR/data/Morrowind.esm" ]; then
    {
        echo ""
        echo "# Morrowind data files installed alongside the game (AROS)"
        echo "data=./data"
        echo "fallback-archive=Morrowind.bsa"
        [ -f "$DESTDIR/data/Tribunal.bsa" ] && echo "fallback-archive=Tribunal.bsa"
        [ -f "$DESTDIR/data/Bloodmoon.bsa" ] && echo "fallback-archive=Bloodmoon.bsa"
        echo "content=Morrowind.esm"
        [ -f "$DESTDIR/data/Tribunal.esm" ] && echo "content=Tribunal.esm"
        [ -f "$DESTDIR/data/Bloodmoon.esm" ] && echo "content=Bloodmoon.esm"
        echo "encoding=win1252"
    } >> "$DESTDIR/openmw.cfg"
fi
SRCDIR="$(cd "$(dirname "$0")/.." && pwd)"
cp "$SRCDIR/LICENSE" "$DESTDIR/LICENSE.txt"
cp "$SRCDIR/README.md" "$DESTDIR/README.txt"
cp "$SRCDIR/AUTHORS.md" "$DESTDIR/AUTHORS.txt"
