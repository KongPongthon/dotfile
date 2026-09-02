#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_DIR
cd "$REPO_DIR"

required_commands=(bash fish jq luac python shellcheck shfmt stylua yq zsh)
missing_commands=()

for command_name in "${required_commands[@]}"; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        missing_commands+=("$command_name")
    fi
done

if ((${#missing_commands[@]} > 0)); then
    printf 'Missing lint commands: %s\n' "${missing_commands[*]}" >&2
    exit 127
fi

bash_files=(install.sh scripts/*)

printf 'Checking Bash syntax...\n'
bash -n "${bash_files[@]}"

printf 'Checking shell scripts with ShellCheck...\n'
shellcheck "${bash_files[@]}"

printf 'Checking shell formatting...\n'
shfmt -d -i 4 -ci "${bash_files[@]}"

printf 'Checking Zsh and Fish syntax...\n'
zsh -n shell/.zshrc
fish -n .config/fish/config.fish

printf 'Checking Lua syntax and maintained modules...\n'
luac -p .config/hypr/*.lua hosts/*/hypr.lua
stylua --check .config/hypr hosts

printf 'Checking JSON configuration...\n'
# The Waybar configs are JSONC: drop whole-line // comments before handing them
# to jq, which only speaks strict JSON.
for jsonc_file in .config/waybar/config.jsonc hosts/*/waybar.jsonc; do
    sed 's|^[[:space:]]*//.*$||' "$jsonc_file" | jq empty
done
jq empty .config/zed/settings.json .config/zed/tasks.json

printf 'Checking TOML and YAML configuration...\n'
python - <<'PY'
import tomllib

for path in ("mise.toml", ".config/atuin/config.toml"):
    with open(path, "rb") as config_file:
        tomllib.load(config_file)
PY
yq '.' .pre-commit-config.yaml .github/workflows/lint.yml >/dev/null

printf 'All lint checks passed.\n'
