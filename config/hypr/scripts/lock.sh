#!/usr/bin/env bash
# Lock the session. With --blank, also turn DPMS off (lid close).
set -euo pipefail

BLANK=0
if [[ "${1:-}" == "--blank" ]]; then
  BLANK=1
fi

loginctl lock-session

# Wait until hyprlock is actually running
for _ in $(seq 1 20); do
  if pidof hyprlock >/dev/null 2>&1; then
    break
  fi
  sleep 0.1
done

if ! pidof hyprlock >/dev/null 2>&1; then
  hyprlock >/dev/null 2>&1 &
  sleep 0.3
fi

if (( BLANK )); then
  sleep 0.3
  hyprctl dispatch dpms off >/dev/null 2>&1 || true
fi
