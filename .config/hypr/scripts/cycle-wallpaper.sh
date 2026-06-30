#!/bin/bash
exec &>/dev/null
DIR="$HOME/wallpapers/cycle"

if [ -n "$1" ] && [ -f "$1" ]; then
    SELECTED="$1"
else
    mapfile -t WALLS < <(find "$DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \))
    COUNT=${#WALLS[@]}
    [ "$COUNT" -eq 0 ] && exit 1
    SELECTED="${WALLS[RANDOM % COUNT]}"
fi

awww img "$SELECTED" --transition-type none --transition-step 255
~/.config/hypr/scripts/wal-post.sh "$SELECTED" &
