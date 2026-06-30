#!/bin/bash
exec &>/dev/null
if pgrep -f "wallpaper-gui.py" >/dev/null; then
  pkill -f "wallpaper-gui.py"
else
  ~/.config/hypr/scripts/wallpaper-gui.py &
fi
