#!/usr/bin/env bash
# ==============================================================================
# Theme switcher — apply a full-desktop palette from token files.
# Palettes live in .config/themes/palettes/; templates in .config/themes/templates/.
# ==============================================================================

set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOTFILES_DIR="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
PALETTE_DIR="$DOTFILES_DIR/.config/themes/palettes"
TEMPLATE_DIR="$DOTFILES_DIR/.config/themes/templates"
STATE_FILE="$HOME/.config/current_theme"
PALETTE_JSON="$HOME/.config/current_palette.json"

PALETTE_ORDER=(
    rumda-dark rumda-light
    tide-dark tide-light
    ember-dark ember-light
    moss-dark moss-light
)

QUIET=0

usage() {
    cat <<'EOF'
Usage: theme-switcher {pick|list|status|toggle|dark|light|restore|apply <id>|<id>}

  pick            Fuzzel menu of palettes (default)
  list            Print palette ids
  status          Print the active palette id
  toggle          Switch dark ↔ light of the current family
  dark|light      Apply that mode of the current family
  restore         Re-apply the saved palette (no notification)
  apply <id>      Apply a palette (e.g. rumda-dark, tide-light)
  <id>            Shorthand for apply <id>
EOF
}

strip_hash() {
    printf '%s' "${1#\#}"
}

lower_hex() {
    strip_hash "$1" | tr 'A-F' 'a-f'
}

hex_to_rgb() {
    local h
    h="$(strip_hash "$1")"
    printf '%d, %d, %d' "$((16#${h:0:2}))" "$((16#${h:2:2}))" "$((16#${h:4:2}))"
}

write_if_changed() {
    local dest="$1"
    local content="$2"
    mkdir -p "$(dirname "$dest")"
    if [[ -L "$dest" ]]; then
        rm -f "$dest"
    fi
    if [[ -f "$dest" ]] && [[ "$(cat "$dest")" == "$content" ]]; then
        return 0
    fi
    printf '%s\n' "$content" >"$dest"
}

TEMPLATE_KEYS=(
    NAME FAMILY MODE
    BG FG FG_SUB SURFACE BORDER HOVER
    ACCENT ACCENT_LIGHT ACCENT_DARK ACCENT_DEEP
    BLUE BLUE_SHADOW CYAN
    ACTIVE ACTIVE_FG DIM BRIGHT WARNING DANGER SUCCESS
    KITTY_C0 KITTY_C1 KITTY_C2 KITTY_C3 KITTY_C4 KITTY_C5 KITTY_C6 KITTY_C7
    KITTY_C8 KITTY_C9 KITTY_C10 KITTY_C11 KITTY_C12 KITTY_C13 KITTY_C14 KITTY_C15
    BORDER_ACTIVE_1 BORDER_ACTIVE_2 BORDER_INACTIVE
    GTK_THEME COLOR_SCHEME WINDOW_ALPHA MAKO_ALPHA FUZZEL_BG_ALPHA LOCK_BG_ALPHA
    TOOLTIP_SHADOW
    QS_BG_SURFACE QS_BG_CARD QS_BG_CARD_HOVER QS_BG_INPUT QS_BORDER_CARD
    QS_STATUS_RED QS_STATUS_GREEN
    KEYCAP_BG KEYCAP_BORDER KEYCAP_TEXT
    KEYCAP_MOD_BG KEYCAP_MOD_BORDER KEYCAP_MOD_TEXT
    SCRIM
    WINDOW_BG
    FUZZEL_BG FUZZEL_TEXT FUZZEL_MATCH FUZZEL_SEL FUZZEL_SEL_TEXT FUZZEL_SEL_MATCH FUZZEL_BORDER
    MAKO_BG MAKO_FG MAKO_BORDER
    LOCK_BG LOCK_FG LOCK_ACCENT LOCK_ACCENT_BASE LOCK_INNER
)

render_template() {
    local src="$1"
    local dest="$2"
    local content key
    content="$(cat "$src")"
    for key in "${TEMPLATE_KEYS[@]}"; do
        content="${content//\{\{$key\}\}/${!key}}"
    done
    write_if_changed "$dest" "$content"
}

normalize_id() {
    local raw="$1"
    case "$raw" in
        dark) printf '%s\n' rumda-dark ;;
        light) printf '%s\n' rumda-light ;;
        "") printf '%s\n' rumda-dark ;;
        *)
            if [[ -f "$PALETTE_DIR/${raw}.conf" ]]; then
                printf '%s\n' "$raw"
            else
                printf '%s\n' rumda-dark
            fi
            ;;
    esac
}

read_current_id() {
    local raw="rumda-dark"
    if [[ -f "$STATE_FILE" ]]; then
        raw="$(tr -d '[:space:]' <"$STATE_FILE")"
    fi
    normalize_id "$raw"
}

palette_family() {
    local id="$1"
    id="${id%-dark}"
    id="${id%-light}"
    printf '%s\n' "$id"
}

palette_mode_of() {
    local id="$1"
    if [[ "$id" == *-light ]]; then
        printf '%s\n' light
    else
        printf '%s\n' dark
    fi
}

load_palette() {
    local id="$1"
    local file="$PALETTE_DIR/${id}.conf"
    if [[ ! -f "$file" ]]; then
        echo "Unknown palette: $id" >&2
        echo "Available:" >&2
        list_ids >&2
        return 1
    fi
    # shellcheck disable=SC1090
    source "$file"

    WINDOW_BG="rgba($(hex_to_rgb "$BG"), ${WINDOW_ALPHA})"

    FUZZEL_BG="$(strip_hash "$BG")${FUZZEL_BG_ALPHA}"
    FUZZEL_TEXT="$(strip_hash "$FG")ff"
    FUZZEL_MATCH="$(strip_hash "$ACCENT_LIGHT")ff"
    FUZZEL_SEL="$(strip_hash "$HOVER")ff"
    FUZZEL_SEL_TEXT="$(strip_hash "$BLUE")ff"
    FUZZEL_SEL_MATCH="$(strip_hash "$ACCENT_LIGHT")ff"
    FUZZEL_BORDER="$(strip_hash "$ACCENT")ff"

    MAKO_BG="${SURFACE}${MAKO_ALPHA}"
    MAKO_FG="${FG}ff"
    MAKO_BORDER="${ACCENT}ff"

    LOCK_BG="rgba($(lower_hex "$BG")${LOCK_BG_ALPHA})"
    LOCK_FG="rgba($(lower_hex "$FG")ff)"
    LOCK_ACCENT="rgba($(lower_hex "$ACCENT_LIGHT")ff)"
    LOCK_ACCENT_BASE="rgba($(lower_hex "$ACCENT")ff)"
    LOCK_INNER="rgba($(lower_hex "$BG")${LOCK_BG_ALPHA})"
}

write_palette_json() {
    local id="$1"
    local is_light=false
    [[ "$MODE" == "light" ]] && is_light=true
    mkdir -p "$(dirname "$PALETTE_JSON")"
    cat >"$PALETTE_JSON" <<EOF
{
  "id": "$id",
  "name": "$NAME",
  "family": "$FAMILY",
  "mode": "$MODE",
  "isLight": $is_light,
  "bgCanvas": "$BG",
  "bgSurface": "$QS_BG_SURFACE",
  "bgCard": "$QS_BG_CARD",
  "bgCardHover": "$QS_BG_CARD_HOVER",
  "bgInput": "$QS_BG_INPUT",
  "bgHover": "$HOVER",
  "borderSubtle": "$BORDER",
  "borderActive": "$ACCENT_LIGHT",
  "borderCard": "$QS_BORDER_CARD",
  "fgPrimary": "$FG",
  "fgSecondary": "$FG_SUB",
  "fgMuted": "$BLUE",
  "accentPurple": "$ACCENT",
  "accentPurpleLight": "$ACCENT_LIGHT",
  "accentBlue": "$BLUE",
  "accentCyan": "$CYAN",
  "statusRed": "$QS_STATUS_RED",
  "statusGreen": "$QS_STATUS_GREEN",
  "keycapBg": "$KEYCAP_BG",
  "keycapBorder": "$KEYCAP_BORDER",
  "keycapText": "$KEYCAP_TEXT",
  "keycapModBg": "$KEYCAP_MOD_BG",
  "keycapModBorder": "$KEYCAP_MOD_BORDER",
  "keycapModText": "$KEYCAP_MOD_TEXT",
  "scrimColor": "$SCRIM"
}
EOF
}

list_ids() {
    local id
    for id in "${PALETTE_ORDER[@]}"; do
        if [[ -f "$PALETTE_DIR/${id}.conf" ]]; then
            printf '%s\n' "$id"
        fi
    done
}

palette_name() {
    local id="$1"
    # shellcheck disable=SC1090
    source "$PALETTE_DIR/${id}.conf"
    printf '%s\n' "$NAME"
}

apply_palette() {
    local id="$1"
    load_palette "$id"

    if [[ "$QUIET" -eq 0 ]]; then
        echo "Applying $NAME ($id)..."
    fi

    render_template "$TEMPLATE_DIR/kitty.conf.tmpl" "$DOTFILES_DIR/.config/kitty/current-theme.conf"
    pkill -SIGUSR1 kitty 2>/dev/null || true

    render_template "$TEMPLATE_DIR/waybar-colors.css.tmpl" "$DOTFILES_DIR/.config/waybar/colors.css"
    touch "$DOTFILES_DIR/.config/waybar/style.css"
    if pgrep -x waybar >/dev/null 2>&1; then
        pkill -SIGUSR2 -x waybar || true
    elif [[ "$QUIET" -eq 0 ]]; then
        nohup "$HOME/.local/bin/waybar" </dev/null >/dev/null 2>&1 &
    fi

    render_template "$TEMPLATE_DIR/rofi.rasi.tmpl" "$DOTFILES_DIR/.config/rofi/colors.rasi"
    render_template "$TEMPLATE_DIR/fuzzel.ini.tmpl" "$DOTFILES_DIR/.config/fuzzel/fuzzel.ini"
    render_template "$TEMPLATE_DIR/mako.conf.tmpl" "$DOTFILES_DIR/.config/mako/config"
    makoctl reload </dev/null >/dev/null 2>&1 || true

    render_template "$TEMPLATE_DIR/btop.theme.tmpl" "$DOTFILES_DIR/.config/btop/themes/current.theme"
    if [[ -f "$DOTFILES_DIR/.config/btop/btop.conf" ]]; then
        sed -i 's/color_theme = .*/color_theme = "current"/' "$DOTFILES_DIR/.config/btop/btop.conf"
    fi

    render_template "$TEMPLATE_DIR/nwg-drawer.css.tmpl" "$DOTFILES_DIR/.config/nwg-drawer/drawer.css"
    render_template "$TEMPLATE_DIR/starship.toml.tmpl" "$DOTFILES_DIR/.config/starship.toml"
    render_template "$TEMPLATE_DIR/gtk.css.tmpl" "$DOTFILES_DIR/.config/gtk-3.0/themes/gtk-current.css"
    write_if_changed "$DOTFILES_DIR/.config/gtk-3.0/gtk.css" '@import "themes/gtk-current.css";'
    write_if_changed "$DOTFILES_DIR/.config/gtk-4.0/gtk.css" '@import "../gtk-3.0/themes/gtk-current.css";'

    render_template "$TEMPLATE_DIR/hyprlock-colors.conf.tmpl" "$DOTFILES_DIR/.config/hypr/hyprlock-colors.conf"

    local a1 a2 ina
    a1="$(lower_hex "$BORDER_ACTIVE_1")"
    a2="$(lower_hex "$BORDER_ACTIVE_2")"
    ina="$(lower_hex "$BORDER_INACTIVE")"
    hyprctl keyword general:col.active_border "rgba(${a1}ff) rgba(${a2}ff) 45deg" </dev/null >/dev/null 2>&1 || true
    hyprctl keyword general:col.inactive_border "rgba(${ina}ff)" </dev/null >/dev/null 2>&1 || true

    gsettings set org.gnome.desktop.interface color-scheme "$COLOR_SCHEME" </dev/null >/dev/null 2>&1 || true
    dconf write /org/gnome/desktop/interface/color-scheme "'$COLOR_SCHEME'" </dev/null >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" </dev/null >/dev/null 2>&1 || true

    write_palette_json "$id"
    mkdir -p "$(dirname "$STATE_FILE")"
    printf '%s\n' "$id" >"$STATE_FILE"

    if [[ "$QUIET" -eq 0 ]]; then
        notify-send "Theme Switcher" "Switched to $NAME" -u low -a "Theme Switcher" </dev/null >/dev/null 2>&1 || true
        echo "✓ Theme switched to $id successfully!"
    fi
}

pick_palette() {
    if ! command -v fuzzel >/dev/null 2>&1; then
        echo "fuzzel not found — use: theme-switcher apply <id>" >&2
        list_ids
        return 1
    fi

    local current id name marker lines=()
    current="$(read_current_id)"
    for id in "${PALETTE_ORDER[@]}"; do
        [[ -f "$PALETTE_DIR/${id}.conf" ]] || continue
        name="$(palette_name "$id")"
        if [[ "$id" == "$current" ]]; then
            marker="● "
        else
            marker="  "
        fi
        lines+=("${marker}${name}")
    done

    local choice
    choice="$(printf '%s\n' "${lines[@]}" | fuzzel --dmenu --prompt="Theme: " --lines="${#lines[@]}" --width=36 || true)"
    [[ -n "$choice" ]] || return 0

    choice="${choice#● }"
    choice="${choice#"${choice%%[![:space:]]*}"}"

    for id in "${PALETTE_ORDER[@]}"; do
        [[ -f "$PALETTE_DIR/${id}.conf" ]] || continue
        if [[ "$(palette_name "$id")" == "$choice" ]]; then
            apply_palette "$id"
            return 0
        fi
    done

    echo "No palette named: $choice" >&2
    return 1
}

ACTION="${1:-pick}"

case "$ACTION" in
    -h | --help | help)
        usage
        exit 0
        ;;
    list)
        list_ids
        exit 0
        ;;
    status)
        echo "Current theme: $(read_current_id)"
        exit 0
        ;;
    pick)
        pick_palette
        ;;
    restore)
        QUIET=1
        apply_palette "$(read_current_id)"
        ;;
    toggle)
        current="$(read_current_id)"
        family="$(palette_family "$current")"
        if [[ "$(palette_mode_of "$current")" == "light" ]]; then
            apply_palette "${family}-dark"
        else
            apply_palette "${family}-light"
        fi
        ;;
    dark | light)
        current="$(read_current_id)"
        family="$(palette_family "$current")"
        apply_palette "${family}-${ACTION}"
        ;;
    apply)
        if [[ -z "${2:-}" ]]; then
            echo "apply requires a palette id" >&2
            usage >&2
            exit 1
        fi
        apply_palette "$(normalize_id "$2")"
        ;;
    *)
        if [[ -f "$PALETTE_DIR/${ACTION}.conf" ]]; then
            apply_palette "$ACTION"
        else
            echo "Unknown command or palette: $ACTION" >&2
            usage >&2
            exit 1
        fi
        ;;
esac
