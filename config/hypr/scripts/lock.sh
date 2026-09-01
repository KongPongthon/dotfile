#!/usr/bin/env bash
# Lock session then blank the display (sleep-like). Wake on mouse/keyboard.
set -euo pipefail

loginctl lock-session

# Give hyprlock a moment to start before blanking
sleep 0.4
hyprctl dispatch dpms off >/dev/null 2>&1 || true
