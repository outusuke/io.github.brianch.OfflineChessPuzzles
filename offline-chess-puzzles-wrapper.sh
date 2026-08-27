#!/bin/sh

set -eu

APPDIR="/app/share/offline-chess-puzzles"
DATADIR="${XDG_DATA_HOME:-$HOME/.local/share}/offline-chess-puzzles"

mkdir -p "$DATADIR"


for item in font translations pieces 1piece.ogg 2pieces.ogg; do
    if [ ! -e "$DATADIR/$item" ]; then
        ln -s "$APPDIR/$item" "$DATADIR/$item"
    fi
done

if [ ! -e "$DATADIR/.env" ] && [ -e "$APPDIR/.env" ]; then
    cp "$APPDIR/.env" "$DATADIR/.env"
fi

if [ ! -e "$DATADIR/settings.json" ] && [ -e "$APPDIR/settings.json" ]; then
    cp "$APPDIR/settings.json" "$DATADIR/settings.json"
fi

if [ ! -e "$DATADIR/ocp.db" ] && [ -e "$APPDIR/ocp.db" ]; then
    cp "$APPDIR/ocp.db" "$DATADIR/ocp.db"
fi

mkdir -p "$DATADIR/puzzles"

cd "$DATADIR"

exec "$APPDIR/offline-chess-puzzles" "$@"
