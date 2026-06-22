#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  wal.sh
#  Browse wallpapers visually with nsxiv thumbnails,
#  set with feh.
#
#  Dependencies: nsxiv, feh  (both installed by install.sh)
#  Wallpapers:   ~/Walllpapers  (cloned by install.sh)
#
#  Controls inside nsxiv thumbnail view:
#    Arrow keys   → navigate thumbnails
#    +  /  -      → zoom thumbnails in/out
#    m            → MARK the wallpaper you want
#    q            → quit & APPLY the marked wallpaper
#    Escape       → cancel without applying anything
# ─────────────────────────────────────────────

# ── CONFIG ────────────────────────────────────
WALLPAPER_DIR="${HOME}/Walllpapers"
# ─────────────────────────────────────────────

# Prefer nsxiv, fall back to sxiv
if command -v nsxiv &>/dev/null; then
  SXIV="nsxiv"
elif command -v sxiv &>/dev/null; then
  SXIV="sxiv"
else
  notify-send "wallpaper-menu" "nsxiv/sxiv not found. Install: sudo pacman -S nsxiv" 2>/dev/null
  echo "Error: nsxiv or sxiv is not installed." >&2
  exit 1
fi

# Make sure the wallpaper directory exists
if [[ ! -d "$WALLPAPER_DIR" ]]; then
  notify-send "wallpaper-menu" "Directory not found: $WALLPAPER_DIR" 2>/dev/null
  echo "Error: WALLPAPER_DIR '$WALLPAPER_DIR' does not exist." >&2
  exit 1
fi

# Gather image files (common formats)
mapfile -d '' images < <(
  find "$WALLPAPER_DIR" \
    -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" \
    -o -iname "*.png" -o -iname "*.webp" \
    -o -iname "*.bmp" -o -iname "*.gif" \) \
    -print0 | sort -z
)

if [[ ${#images[@]} -eq 0 ]]; then
  notify-send "wallpaper-menu" "No images found in $WALLPAPER_DIR" 2>/dev/null
  echo "Error: no images found in '$WALLPAPER_DIR'." >&2
  exit 1
fi

# Open nsxiv in thumbnail mode (-t), output marked file path on quit (-o)
chosen_path=$("$SXIV" -t -o "${images[@]}" 2>/dev/null | head -n 1)

# Exit silently if nothing was marked
[[ -z "$chosen_path" ]] && exit 0

# ── Set wallpaper with feh ────────────────────
feh --bg-fill "$chosen_path"

notify-send "wallpaper-menu" "Wallpaper set: $(basename "$chosen_path")" 2>/dev/null
