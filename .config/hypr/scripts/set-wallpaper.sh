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

notify() {
  echo "$*" >&2
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u critical "Wallpaper" "$*" 2>/dev/null || true
  fi
}

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

wait_compositor() {
  local i
  for i in $(seq 1 50); do
    if command -v hyprctl >/dev/null 2>&1; then
      if hyprctl monitors >/dev/null 2>&1; then
        return 0
      fi
    elif [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
      return 0
    fi
    sleep 0.2
  done
  return 1
}

start_daemon() {
  if ((${#DAEMON_ARGS[@]})); then
    "$WWW_DAEMON" "${DAEMON_ARGS[@]}" &
  else
    "$WWW_DAEMON" &
  fi
}

wait_ready() {
  local i
  for i in $(seq 1 50); do
    if "$WWW" query >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.2
  done
  return 1
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
  start_daemon
  if wait_ready; then
    return 0
  fi
  # Wayland may not have been ready on the first attempt
  start_daemon
  wait_ready
}

WALL_DIR="$(pick_dir)" || {
  notify "No wallpaper directory found"
  exit 1
}

MODE="${1:-}"
if [[ "$MODE" == "random" || -z "$MODE" ]]; then
  mapfile -t files < <(find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) ! -path '*/Dynamic-Wallpapers/*')
  ((${#files[@]} > 0)) || { notify "No wallpapers in $WALL_DIR"; exit 1; }
  TARGET="${files[RANDOM % ${#files[@]}]}"
else
  TARGET="$MODE"
fi

TARGET="$(realpath -e "$TARGET")"

# Always refresh lock wallpaper symlink (even if wallpaper daemon missing)
update_lock_bg "$TARGET"

detect_www
if [[ -z "$WWW" ]]; then
  notify "awww/swww not installed — desktop wallpaper skipped (lock.bg only)"
  exit 1
fi

wait_compositor || true

if ! ensure_daemon; then
  notify "Wallpaper daemon ($WWW_DAEMON) did not become ready"
  exit 1
fi

"$WWW" img "$TARGET" --transition-type fade --transition-duration 1
echo "Wallpaper: $TARGET"
