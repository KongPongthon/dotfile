#!/usr/bin/env bash
# ==============================================================================
# Tanakorn's Dynamic Theme Switcher: Rumda Dark ⇄ Rumda Light (Rainy Palette)
# ==============================================================================

set -e

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOTFILES_DIR="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
STATE_FILE="$HOME/.config/current_theme"

activate_file() {
    local source_file="$1"
    local active_file="$2"

    if ! cmp -s "$source_file" "$active_file"; then
        cp "$source_file" "$active_file"
    fi
}

# Current state or default to dark
CURRENT_THEME="dark"
if [ -f "$STATE_FILE" ]; then
    CURRENT_THEME="$(tr -d '[:space:]' <"$STATE_FILE")"
fi
if [ "$CURRENT_THEME" != "dark" ] && [ "$CURRENT_THEME" != "light" ]; then
    CURRENT_THEME="dark"
fi

ACTION="${1:-toggle}"

case "$ACTION" in
    light)
        TARGET="light"
        ;;
    dark)
        TARGET="dark"
        ;;
    toggle)
        if [ "$CURRENT_THEME" = "light" ]; then
            TARGET="dark"
        else
            TARGET="light"
        fi
        ;;
    status)
        echo "Current theme: $CURRENT_THEME"
        exit 0
        ;;
    *)
        echo "Usage: $0 {dark|light|toggle|status}"
        exit 1
        ;;
esac

echo "Applying $TARGET theme..."

# 1. Kitty Terminal Theme
if [ -f "$DOTFILES_DIR/.config/kitty/themes/rumda-$TARGET.conf" ]; then
    activate_file "$DOTFILES_DIR/.config/kitty/themes/rumda-$TARGET.conf" "$DOTFILES_DIR/.config/kitty/current-theme.conf"
    # Live reload Kitty
    pkill -SIGUSR1 kitty 2>/dev/null || true
fi

# 2. Waybar Theme
if [ -f "$DOTFILES_DIR/.config/waybar/themes/style-$TARGET.css" ]; then
    activate_file "$DOTFILES_DIR/.config/waybar/themes/style-$TARGET.css" "$DOTFILES_DIR/.config/waybar/style.css"
    # Live reload Waybar. If it is not up yet, start the watchdog wrapper; its
    # flock guard makes a redundant start a no-op rather than a second bar.
    if pgrep -x waybar >/dev/null 2>&1; then
        pkill -SIGUSR2 -x waybar || true
    else
        nohup "$HOME/.local/bin/waybar" </dev/null >/dev/null 2>&1 &
    fi
fi

# 3. Rofi Theme
if [ -f "$DOTFILES_DIR/.config/rofi/themes/rumda-$TARGET.rasi" ]; then
    ln -sfn "themes/rumda-$TARGET.rasi" "$DOTFILES_DIR/.config/rofi/colors.rasi"
fi

# 4. Fuzzel Launcher Theme
if [ -f "$DOTFILES_DIR/.config/fuzzel/themes/fuzzel-$TARGET.ini" ]; then
    activate_file "$DOTFILES_DIR/.config/fuzzel/themes/fuzzel-$TARGET.ini" "$DOTFILES_DIR/.config/fuzzel/fuzzel.ini"
fi

# 5. Mako Notification Daemon Theme
if [ -f "$DOTFILES_DIR/.config/mako/themes/config-$TARGET" ]; then
    activate_file "$DOTFILES_DIR/.config/mako/themes/config-$TARGET" "$DOTFILES_DIR/.config/mako/config"
    makoctl reload </dev/null >/dev/null 2>&1 || true
fi

# 6. Btop Resource Monitor Theme
if [ -f "$DOTFILES_DIR/.config/btop/btop.conf" ]; then
    sed -i "s/color_theme = .*/color_theme = \"rainy-$TARGET\"/" "$DOTFILES_DIR/.config/btop/btop.conf"
fi

# 7. Nwg-drawer Theme
if [ -f "$DOTFILES_DIR/.config/nwg-drawer/themes/drawer-$TARGET.css" ]; then
    activate_file "$DOTFILES_DIR/.config/nwg-drawer/themes/drawer-$TARGET.css" "$DOTFILES_DIR/.config/nwg-drawer/drawer.css"
fi

# 8. Starship Shell Prompt Theme
if [ -f "$DOTFILES_DIR/.config/starship-themes/starship-$TARGET.toml" ]; then
    activate_file "$DOTFILES_DIR/.config/starship-themes/starship-$TARGET.toml" "$DOTFILES_DIR/.config/starship.toml"
fi

# 9. Hyprland Border Colors (live only; the source config stays untouched)
if [ "$TARGET" = "light" ]; then
    hyprctl keyword general:col.active_border "rgba(8E86C6ff) rgba(6E64A6ff) 45deg" </dev/null >/dev/null 2>&1 || true
    hyprctl keyword general:col.inactive_border "rgba(C8B9ACff)" </dev/null >/dev/null 2>&1 || true
else
    hyprctl keyword general:col.active_border "rgba(9890D0ff) rgba(817BBEff) 45deg" </dev/null >/dev/null 2>&1 || true
    hyprctl keyword general:col.inactive_border "rgba(423E63ff)" </dev/null >/dev/null 2>&1 || true
fi

# 10. System-Wide Color Scheme (XDG Portal, GTK 3/4, Browsers, VSCode, Electron)
if [ "$TARGET" = "light" ]; then
    # FreeDesktop & GNOME Portal (Broadcasts to Firefox, Chrome, Brave, VSCode, Discord, etc.)
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' </dev/null >/dev/null 2>&1 || true
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'" </dev/null >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' </dev/null >/dev/null 2>&1 || true

    # GTK 3 & GTK 4 Palettes & Settings
    if [ -f "$DOTFILES_DIR/.config/gtk-3.0/themes/gtk-light.css" ]; then
        echo '@import "themes/gtk-light.css";' >"$DOTFILES_DIR/.config/gtk-3.0/gtk.css"
        echo '@import "../gtk-3.0/themes/gtk-light.css";' >"$DOTFILES_DIR/.config/gtk-4.0/gtk.css"
    fi
else
    # FreeDesktop & GNOME Portal
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' </dev/null >/dev/null 2>&1 || true
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'" </dev/null >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' </dev/null >/dev/null 2>&1 || true

    # GTK 3 & GTK 4 Palettes & Settings
    if [ -f "$DOTFILES_DIR/.config/gtk-3.0/themes/gtk-dark.css" ]; then
        echo '@import "themes/gtk-dark.css";' >"$DOTFILES_DIR/.config/gtk-3.0/gtk.css"
        echo '@import "../gtk-3.0/themes/gtk-dark.css";' >"$DOTFILES_DIR/.config/gtk-4.0/gtk.css"
    fi
fi

# 11. Save current state
echo "$TARGET" >"$STATE_FILE"

# 12. Send notification
notify-send "🎨 Theme Switcher" "Switched to ${TARGET^^} Theme (System & Apps updated)" -u low -a "Theme Switcher" </dev/null >/dev/null 2>&1 || true

echo "✓ Theme switched to $TARGET successfully!"
