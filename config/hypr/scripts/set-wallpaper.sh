#!/usr/bin/env bash
# Set wallpaper via awww (or swww fallback). Usage: set-wallpaper.sh [random|path]
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

detect_www() {
  if command -v awww >/dev/null 2>&1; then
    WWW=awww
    WWW_DAEMON=awww-daemon
    CACHE_DIR="${HOME}/.cache/awww"
    DAEMON_ARGS=()
  elif command -v swww >/dev/null 2>&1; then
    WWW=swww
    WWW_DAEMON=swww-daemon
    CACHE_DIR="${HOME}/.cache/swww"
    DAEMON_ARGS=(--format xrgb)
  else
    WWW=""
    WWW_DAEMON=""
    CACHE_DIR=""
    DAEMON_ARGS=()
  fi
}

ensure_daemon() {
  mkdir -p "$CACHE_DIR"
  if [[ "$WWW" == "awww" && ! -f "${CACHE_DIR}/.cache_cleared" ]]; then
    awww clear-cache >/dev/null 2>&1 || true
    touch "${CACHE_DIR}/.cache_cleared"
  fi
  if "$WWW" query >/dev/null 2>&1; then
    return 0
  fi
  if ((${#DAEMON_ARGS[@]})); then
    "$WWW_DAEMON" "${DAEMON_ARGS[@]}" &
  else
    "$WWW_DAEMON" &
  fi
  local i
  for i in $(seq 1 25); do
    sleep 0.2
    if "$WWW" query >/dev/null 2>&1; then
      return 0
    fi
  done
  echo "Wallpaper daemon ($WWW_DAEMON) did not become ready" >&2
  return 1
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

# Always refresh lock wallpaper symlink (even if wallpaper daemon missing)
update_lock_bg "$TARGET"

detect_www
if [[ -z "$WWW" ]]; then
  echo "Wallpaper (lock.bg only): $TARGET"
  exit 0
fi

ensure_daemon
"$WWW" img "$TARGET" --transition-type fade --transition-duration 1
echo "Wallpaper: $TARGET"
