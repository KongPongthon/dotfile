#!/usr/bin/env bash
# Set wallpaper via swww. Usage: set-wallpaper.sh [random|path]
set -euo pipefail

DIRS=(
  "${HOME}/รูปภาพ/wallpapers"
  "${HOME}/Pictures/wallpapers"
  "${HOME}/.local/share/wallpapers"
  "${HOME}/dotfiles/wallpapers"
)

LOCK_BG="${HOME}/.config/hypr/lock.bg"

pick_dir() {
  for d in "${DIRS[@]}"; do
    if [[ -d "$d" ]]; then
      echo "$d"
      return 0
    fi
  done
  return 1
}

update_lock_bg() {
  local img="$1"
  mkdir -p "$(dirname "$LOCK_BG")"
  ln -sfn "$img" "$LOCK_BG"
}

WALL_DIR="$(pick_dir)" || {
  echo "No wallpaper directory found" >&2
  exit 1
}

MODE="${1:-}"
if [[ "$MODE" == "random" || -z "$MODE" ]]; then
  mapfile -t files < <(find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) ! -path '*/Dynamic-Wallpapers/*')
  ((${#files[@]} > 0)) || { echo "No wallpapers in $WALL_DIR" >&2; exit 1; }
  TARGET="${files[RANDOM % ${#files[@]}]}"
else
  TARGET="$MODE"
fi

# Always refresh lock wallpaper symlink (even if swww missing)
update_lock_bg "$TARGET"

command -v swww >/dev/null || { echo "Wallpaper (lock.bg only): $TARGET"; exit 0; }
swww query >/dev/null 2>&1 || swww-daemon --format xrgb &
sleep 0.2
swww img "$TARGET" --transition-type fade --transition-duration 1
echo "Wallpaper: $TARGET"
