#!/usr/bin/env bash

set -uo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
readonly SCRIPT_PATH
REPO_DIR="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
readonly REPO_DIR

passes=0
warnings=0
failures=0

pass() {
    passes=$((passes + 1))
    printf '[OK]   %s\n' "$1"
}

warn() {
    warnings=$((warnings + 1))
    printf '[WARN] %s\n' "$1"
}

fail() {
    failures=$((failures + 1))
    printf '[FAIL] %s\n' "$1"
}

check_command() {
    local command_name="$1"
    local importance="${2:-required}"

    if command -v "$command_name" >/dev/null 2>&1; then
        pass "command: $command_name"
    elif [ "$importance" = "optional" ]; then
        warn "optional command missing: $command_name"
    else
        fail "required command missing: $command_name"
    fi
}

check_link() {
    local destination="$1"
    local expected="$2"

    if [ "$(readlink -f "$destination" 2>/dev/null)" = "$expected" ]; then
        pass "linked: $destination"
    else
        warn "not linked to dotfiles: $destination"
    fi
}

host_id="$("$REPO_DIR/scripts/host-id")"

printf 'Dotfiles doctor: %s\n\n' "$REPO_DIR"

printf 'Core Commands:\n'
for command_name in git jq zsh starship hyprctl waybar kitty fuzzel swaync grim slurp wl-copy; do
    check_command "$command_name"
done

printf '\nOptional / Developer Commands:\n'
for command_name in atuin delta easyeffects lazygit luac mise pre-commit quickshell shellcheck shfmt stylua tesseract watchexec yq fish swappy hyprpicker cursor google-chrome-stable; do
    check_command "$command_name" optional
done

printf '\nConfiguration Symlinks:\n'
check_link "$HOME/.config/hypr" "$REPO_DIR/.config/hypr"
check_link "$HOME/.config/waybar" "$REPO_DIR/.config/waybar"
check_link "$HOME/.config/kitty" "$REPO_DIR/.config/kitty"
check_link "$HOME/.config/fuzzel" "$REPO_DIR/.config/fuzzel"
check_link "$HOME/.config/swaync" "$REPO_DIR/.config/swaync"
check_link "$HOME/.config/wlogout" "$REPO_DIR/.config/wlogout"
check_link "$HOME/.config/atuin" "$REPO_DIR/.config/atuin"
check_link "$HOME/.config/quickshell" "$REPO_DIR/.config/quickshell"
check_link "$HOME/.zshrc" "$REPO_DIR/shell/.zshrc"

printf '\nHost Layer (%s):\n' "$host_id"
if [ -d "$REPO_DIR/hosts/$host_id" ]; then
    pass "hosts/$host_id exists"
else
    fail "hosts/$host_id missing (cp -r hosts/_template hosts/$host_id)"
fi
check_link "$HOME/.config/waybar/host.jsonc" "$REPO_DIR/hosts/$host_id/waybar.jsonc"
check_link "$HOME/.config/kanshi/config" "$REPO_DIR/hosts/$host_id/kanshi"
check_link "$REPO_DIR/.config/hypr/hosts" "$REPO_DIR/hosts"

printf '\nScript Symlinks in ~/.local/bin:\n'
check_link "$HOME/.local/bin/audio-switch" "$REPO_DIR/scripts/audio-switch"
check_link "$HOME/.local/bin/battery-saver" "$REPO_DIR/scripts/battery-saver"
check_link "$HOME/.local/bin/dotfiles-doctor" "$REPO_DIR/scripts/doctor.sh"
check_link "$HOME/.local/bin/hotkey-cheatsheet" "$REPO_DIR/scripts/hotkey-cheatsheet"
check_link "$HOME/.local/bin/dotfiles-host-id" "$REPO_DIR/scripts/host-id"
check_link "$HOME/.local/bin/install-dotfiles-packages" "$REPO_DIR/scripts/install-packages.sh"
check_link "$HOME/.local/bin/network-menu" "$REPO_DIR/scripts/network-menu"
check_link "$HOME/.local/bin/ocr-snip" "$REPO_DIR/scripts/ocr-snip"
check_link "$HOME/.local/bin/powermenu" "$REPO_DIR/scripts/powermenu"
check_link "$HOME/.local/bin/setup-dev-tools" "$REPO_DIR/scripts/setup-dev-tools.sh"
check_link "$HOME/.local/bin/smart-snip" "$REPO_DIR/scripts/smart-snip"
check_link "$HOME/.local/bin/theme-switcher" "$REPO_DIR/scripts/theme-switcher.sh"
check_link "$HOME/.local/bin/waybar" "$REPO_DIR/scripts/waybar"
check_link "$HOME/.local/bin/waybar-fan" "$REPO_DIR/scripts/waybar-fan"

printf '\nConfiguration Syntax:\n'
if bash -n "$REPO_DIR/install.sh" "$REPO_DIR"/scripts/*; then
    pass "Bash syntax"
else
    fail "Bash syntax"
fi

if zsh -n "$REPO_DIR/shell/.zshrc"; then
    pass "Zsh syntax"
else
    fail "Zsh syntax"
fi

if fish -n "$REPO_DIR/.config/fish/config.fish"; then
    pass "Fish syntax"
else
    fail "Fish syntax"
fi

# The Waybar configs are JSONC: drop whole-line // comments before handing them
# to jq, which only speaks strict JSON.
jsonc_ok=0
for jsonc_file in "$REPO_DIR/.config/waybar/config.jsonc" "$REPO_DIR"/hosts/*/waybar.jsonc; do
    sed 's|^[[:space:]]*//.*$||' "$jsonc_file" | jq empty || jsonc_ok=1
done
if [ "$jsonc_ok" -eq 0 ] && jq empty "$REPO_DIR/.config/zed/settings.json" "$REPO_DIR/.config/zed/tasks.json"; then
    pass "JSON configuration"
else
    fail "JSON configuration"
fi

if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && command -v hyprctl >/dev/null 2>&1; then
    config_errors="$(hyprctl configerrors 2>/dev/null || true)"
    if [ -z "$config_errors" ]; then
        pass "Hyprland runtime config"
    else
        fail "Hyprland runtime config: $config_errors"
    fi
fi

if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
        pass "Docker daemon"
    else
        warn "Docker is installed but the daemon is unavailable"
    fi
fi

if command -v delta >/dev/null 2>&1; then
    if [ "$(git config --global --get core.pager 2>/dev/null)" = "delta" ]; then
        pass "Git Delta pager"
    else
        warn "Delta is installed but Git is not configured; run setup-dev-tools"
    fi
fi

printf '\nSummary: %d passed, %d warnings, %d failures\n' "$passes" "$warnings" "$failures"
if ((failures > 0)); then
    exit 1
fi
