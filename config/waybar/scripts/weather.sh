#!/usr/bin/env bash
# Lightweight weather for waybar — no JaKooLit deps.
# Uses wttr.in (JSON). Optional override: WEATHER_LOC="Bangkok" or "13.75,100.50"
set -euo pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-weather"
CACHE_FILE="$CACHE_DIR/weather.json"
CACHE_MAX_AGE="${WEATHER_CACHE_SECONDS:-1800}" # 30 minutes
LOC="${WEATHER_LOC:-}"

if ! mkdir -p "$CACHE_DIR" 2>/dev/null; then
  CACHE_DIR="/tmp/waybar-weather-${USER:-user}"
  CACHE_FILE="$CACHE_DIR/weather.json"
  mkdir -p "$CACHE_DIR"
fi

need_refresh() {
  [[ ! -f "$CACHE_FILE" ]] && return 0
  local age
  age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
  (( age >= CACHE_MAX_AGE ))
}

fetch() {
  local url="https://wttr.in/${LOC}?format=j1"
  curl -fsS --max-time 8 "$url" -o "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"
}

if need_refresh; then
  fetch || true
fi

if [[ ! -f "$CACHE_FILE" ]]; then
  printf '{"text":"☁️ ?","tooltip":"Weather unavailable","class":"weather"}\n'
  exit 0
fi

python3 - "$CACHE_FILE" <<'PY'
import json, sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text())
cur = data["current_condition"][0]
area = data.get("nearest_area", [{}])[0]
place = area.get("areaName", [{"value": "?"}])[0]["value"]
region = area.get("region", [{"value": ""}])[0]["value"]
temp = cur.get("temp_C", "?")
feels = cur.get("FeelsLikeC", temp)
desc = cur.get("weatherDesc", [{"value": ""}])[0]["value"]
humidity = cur.get("humidity", "?")
wind = cur.get("windspeedKmph", "?")
code = cur.get("weatherCode", "113")

# Simple icon map (wttr weather codes)
icons = {
    "113": "☀️", "116": "⛅", "119": "☁️", "122": "☁️",
    "143": "🌫️", "176": "🌦️", "179": "🌧️", "182": "🌧️",
    "185": "🌧️", "200": "⛈️", "227": "🌨️", "230": "❄️",
    "248": "🌫️", "260": "🌫️", "263": "🌦️", "266": "🌧️",
    "281": "🌧️", "284": "🌧️", "293": "🌦️", "296": "🌧️",
    "299": "🌧️", "302": "🌧️", "305": "🌧️", "308": "🌧️",
    "311": "🌧️", "314": "🌧️", "317": "🌧️", "320": "🌨️",
    "323": "🌨️", "326": "🌨️", "329": "❄️", "332": "❄️",
    "335": "❄️", "338": "❄️", "350": "🌧️", "353": "🌦️",
    "356": "🌧️", "359": "🌧️", "362": "🌧️", "365": "🌧️",
    "368": "🌨️", "371": "❄️", "374": "🌧️", "377": "🌧️",
    "386": "⛈️", "389": "⛈️", "392": "⛈️", "395": "❄️",
}
icon = icons.get(str(code), "🌡️")
text = f"{icon} {temp}°"
loc = f"{place}" + (f", {region}" if region else "")
tooltip = f"{loc}\n{desc}\n{temp}°C (feels {feels}°C)\nHumidity {humidity}% · Wind {wind} km/h"
out = {"text": text, "tooltip": tooltip, "class": "weather", "alt": desc}
print(json.dumps(out, ensure_ascii=False))
PY
