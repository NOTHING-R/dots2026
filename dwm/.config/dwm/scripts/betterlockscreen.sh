#!/bin/bash

# Function: Read wallpaper from FEH
get_wallpaper_from_feh() {
  local fehbg="$HOME/.fehbg"

  if [[ -f "$fehbg" ]]; then
    grep feh "$fehbg" | awk '{print $NF}' | tr -d "'"
    return 0
  else
    return 1
  fi
}

echo "Detecting FEH wallpaper..."

WALLPAPER=$(get_wallpaper_from_feh)

if [[ $? -ne 0 || -z "$WALLPAPER" ]]; then
  echo "❌ No FEH wallpaper found."
  exit 1
fi

echo "Found FEH wallpaper:"
echo "$WALLPAPER"

# Update betterlockscreen
echo "Updating betterlockscreen..."
betterlockscreen -u "$WALLPAPER"

if [[ $? -eq 0 ]]; then
  echo "✅ betterlockscreen wallpaper updated."
else
  echo "❌ Failed to update betterlockscreen."
fi
