#!/bin/bash
exec &>/dev/null
sleep 2
SELECTED="$1"
[ -z "$SELECTED" ] && exit 1

wal -i "$SELECTED" -n --cols16
sync
swaync-client --reload-css
cat ~/.cache/wal/colors-kitty.conf > ~/.config/kitty/current-theme.conf
COLOR1=$(awk 'match($0, /color2=\47(.*)\47/,a) { print a[1] }' ~/.cache/wal/colors.sh)
COLOR2=$(awk 'match($0, /color3=\47(.*)\47/,a) { print a[1] }' ~/.cache/wal/colors.sh)
CAVA="$HOME/.config/cava/config"
sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '$COLOR1'/" "$CAVA"
sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '$COLOR2'/" "$CAVA"
pkill -USR2 cava 2>/dev/null
source ~/.cache/wal/colors.sh 2>/dev/null
cp "$SELECTED" ~/wallpapers/pywallpaper.jpg
