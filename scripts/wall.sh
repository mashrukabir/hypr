#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Listing all image files
wallpapers=$(find "$WALLPAPER_DIR" -type f \( -iname "*.gif" -o -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -print0 | sort -z | xargs -0 basename -a)

if [ -z "$wallpapers" ]; then
  echo "No wallpapers found in $WALLPAPER_DIR"
  exit 1
fi

selected_file=$(echo "$wallpapers" | wofi --dmenu \
  --prompt "Pick wallpaper" \
  --width 15% \
  --height 45%)

if [ -n "$selected_file" ]; then
  selected_wallpaper="$WALLPAPER_DIR/$selected_file"
  swww img "$selected_wallpaper" --transition-fps 60 --transition-type wipe
else
  echo "No wallpaper selected"
fi
