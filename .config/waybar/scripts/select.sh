#!/bin/bash
WAYBAR_DIR="$HOME/.config/waybar"
STYLECSS="$WAYBAR_DIR/style.css"
CONFIG="$WAYBAR_DIR/config"
THEMES="$WAYBAR_DIR/themes"

themes="default
experimental
line
zen
hidden
dots
bottom
dock
flat"

main() {
  choice=$(echo "$themes" | wofi -c ~/.config/wofi/waybar -s ~/.config/wofi/style-waybar.css --show dmenu --prompt "  Select Waybar Theme" -n)
  [ -z "$choice" ] && exit
  cat "$THEMES/$choice/style-$choice.css" > "$STYLECSS"
  cat "$THEMES/$choice/config-$choice" > "$CONFIG"
  pkill waybar && waybar
}
main
