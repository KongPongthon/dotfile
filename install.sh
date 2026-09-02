#!/usr/bin/env bash
# Hyprland dotfiles installer (testdot architecture, MSI GF63 personal layer)
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
BOLD="\033[1m"
NC="\033[0m"

print_banner() {
    echo -e "${CYAN}"
    echo "============================================================"
    echo "          Hyprland Dotfiles Setup & Installer"
    echo "============================================================"
    echo -e "${NC}"
}

show_help() {
    print_banner
    echo -e "${BOLD}Usage:${NC} ./install.sh [--host ID] [OPTION]"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo "  -l, --link             Symlink all configs and helper scripts (Default)"
    echo "      --fix-hypr         Repair ~/.config/hypr only (use from TTY if login fails)"
    echo "  -p, --packages [CAT..] Install packages (core desktop dev aur)"
    echo "  -z, --zsh              Install Oh-My-Zsh and custom plugins"
    echo "  -d, --dev              Configure dev tools (Git Delta, zdiff3, pre-commit)"
    echo "  -b, --build            Compile Hyprland helper binaries (waybar-fix.so)"
    echo "  -a, --all              Full setup (Packages + Zsh + Links + Build + extras)"
    echo "  -H, --host ID          Pin this machine's host layer, then run the rest"
    echo "  -h, --help             Show this help message"
    echo ""
}

link_file() {
    local src="$1"
    local dest="$2"
    local name="$3"

    if [ ! -e "$src" ]; then
        echo -e "${RED}[!] Source not found: $src${NC}"
        return 1
    fi

    mkdir -p "$(dirname "$dest")"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ "$(readlink -f "$dest" 2>/dev/null)" = "$(readlink -f "$src")" ]; then
            echo -e "${GREEN}[OK] Already linked: ${name}${NC}"
            return 0
        fi

        mkdir -p "$BACKUP_DIR"
        echo -e "${YELLOW}[Backup] Moving existing $dest to $BACKUP_DIR/${NC}"
        mv "$dest" "$BACKUP_DIR/"
    fi

    ln -sfn "$src" "$dest"
    echo -e "${GREEN}[Link] Linked ${name} -> $dest${NC}"
}

# Hyprland 0.55+ looks for ~/.config/hypr/hyprland.lua. If that file is missing
# it tries to mkdir the parent, then write a default lua config. A symlink at
# ~/.config/hypr makes create_directories() fail with "File exists" and the
# compositor exits before login — the failure seen on VM reboot.
link_hypr_tree() {
    local src="$DOTFILES_DIR/.config/hypr"
    local dest="$CONFIG_DIR/hypr"

    if [ -L "$dest" ]; then
        mkdir -p "$BACKUP_DIR"
        echo -e "${YELLOW}[Backup] ~/.config/hypr is a symlink; moving it to $BACKUP_DIR/${NC}"
        mv "$dest" "$BACKUP_DIR/hypr"
    elif [ -e "$dest" ] && [ ! -d "$dest" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
    fi
    mkdir -p "$dest"

    local item
    for item in hyprland.lua hypridle.conf hyprlock.conf waybar-fix.c waybar-fix.so scripts; do
        if [ -e "$src/$item" ]; then
            link_file "$src/$item" "$dest/$item" "hypr/$item"
        fi
    done
    link_file "$DOTFILES_DIR/hosts" "$dest/hosts" "hypr/hosts"
}

build_helpers() {
    echo -e "\n${CYAN}Building Hyprland helpers...${NC}"
    local waybar_c="$DOTFILES_DIR/.config/hypr/waybar-fix.c"
    local waybar_so="$DOTFILES_DIR/.config/hypr/waybar-fix.so"

    if [ -f "$waybar_c" ]; then
        if command -v gcc >/dev/null 2>&1; then
            gcc -shared -fPIC -o "$waybar_so" "$waybar_c" -ldl
            echo -e "${GREEN}[Build] Compiled waybar-fix.so successfully.${NC}"
        elif [ ! -f "$waybar_so" ]; then
            echo -e "${YELLOW}[Warn] gcc not found; cannot compile waybar-fix.so.${NC}"
        fi
    fi
}

setup_zsh_plugins() {
    echo -e "\n${CYAN}Setting up Oh-My-Zsh and plugins...${NC}"
    if [ -x "$DOTFILES_DIR/shell/omz-setup.sh" ]; then
        bash "$DOTFILES_DIR/shell/omz-setup.sh"
    else
        if [ ! -d "$HOME/.oh-my-zsh" ]; then
            git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" --depth=1 || true
        fi
        local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
        mkdir -p "$zsh_custom/plugins"
        [ -d "$zsh_custom/plugins/zsh-autosuggestions" ] ||
            git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions" --depth=1 || true
        [ -d "$zsh_custom/plugins/zsh-syntax-highlighting" ] ||
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting" --depth=1 || true
    fi

    if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
        echo -e "${YELLOW}[Zsh] Changing default shell to zsh...${NC}"
        chsh -s "$(command -v zsh)" || echo -e "${YELLOW}[Warn] chsh failed — run: chsh -s $(command -v zsh)${NC}"
    fi
}

install_packages() {
    local cats=("$@")
    echo -e "\n${CYAN}Installing system packages...${NC}"
    bash "$DOTFILES_DIR/scripts/install-packages.sh" "${cats[@]}"
}

setup_dev() {
    echo -e "\n${CYAN}Configuring developer environment...${NC}"
    bash "$DOTFILES_DIR/scripts/setup-dev-tools.sh"
}

resolve_host() {
    if [ -n "${HOST_ID_OVERRIDE:-}" ]; then
        printf '%s' "$HOST_ID_OVERRIDE"
        return
    fi
    "$DOTFILES_DIR/scripts/host-id"
}

link_host_layer() {
    local host
    host="$(resolve_host)"
    local host_dir="$DOTFILES_DIR/hosts/$host"

    echo -e "\n${CYAN}Host layer: ${BOLD}${host}${NC}"

    if [ ! -d "$host_dir" ]; then
        echo -e "${YELLOW}[Host] No layer at hosts/${host}. Creating one from the template.${NC}"
        cp -r "$DOTFILES_DIR/hosts/_template" "$host_dir"
        echo -e "${YELLOW}[Host] Edit hosts/${host}/ before relying on it (see hosts/README.md).${NC}"
    fi

    link_file "$host_dir/waybar.jsonc" "$CONFIG_DIR/waybar/host.jsonc" "Waybar host layer"

    mkdir -p "$CONFIG_DIR/kanshi"
    link_file "$host_dir/kanshi" "$CONFIG_DIR/kanshi/config" "Kanshi host layer"
}

setup_wallpapers() {
    local dest="$HOME/รูปภาพ/wallpapers"
    mkdir -p "$HOME/รูปภาพ" "$HOME/Pictures"
    if [ ! -d "$dest" ]; then
        mkdir -p "$dest"
        if [ -d "$DOTFILES_DIR/wallpapers" ]; then
            cp -a "$DOTFILES_DIR/wallpapers/." "$dest/"
            echo -e "${GREEN}[OK] Seeded wallpapers into $dest${NC}"
        fi
    else
        echo -e "${GREEN}[OK] Wallpaper dir exists: $dest${NC}"
    fi
    if [ ! -e "$HOME/Pictures/wallpapers" ]; then
        ln -sfn "$dest" "$HOME/Pictures/wallpapers" 2>/dev/null || true
    fi
}

setup_lock_bg() {
    echo -e "\n${CYAN}Setting hyprlock wallpaper symlink...${NC}"
    local lock_bg="$HOME/.config/hypr/lock.bg"
    local candidates=(
        "$HOME/รูปภาพ/wallpapers/Night monochrome.jpg"
        "$DOTFILES_DIR/wallpapers/Night monochrome.jpg"
        "$HOME/Pictures/wallpapers/Night monochrome.jpg"
    )
    local img="" c
    for c in "${candidates[@]}"; do
        if [ -f "$c" ]; then
            img="$c"
            break
        fi
    done
    if [ -z "$img" ]; then
        for d in "$HOME/รูปภาพ/wallpapers" "$DOTFILES_DIR/wallpapers" "$HOME/Pictures/wallpapers"; do
            [ -d "$d" ] || continue
            img="$(find "$d" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) ! -path '*/Dynamic-Wallpapers/*' | head -n1 || true)"
            [ -n "$img" ] && break
        done
    fi
    if [ -n "$img" ]; then
        mkdir -p "$(dirname "$lock_bg")"
        ln -sfn "$img" "$lock_bg"
        echo -e "${GREEN}[OK] lock.bg -> $img${NC}"
    else
        echo -e "${YELLOW}[Warn] No wallpaper found for lock.bg${NC}"
    fi
}

setup_sddm() {
    local theme_dir="/usr/share/sddm/themes/simple_sddm_2"
    local theme_conf="$theme_dir/theme.conf"
    local bg_src="$DOTFILES_DIR/wallpapers/Night monochrome.jpg"
    local bg_dst="$theme_dir/Backgrounds/dotfiles-bg.jpg"
    local our_conf="$DOTFILES_DIR/.config/sddm/theme.conf"

    if [ ! -d "$theme_dir" ]; then
        echo -e "${YELLOW}[Warn] SDDM theme simple_sddm_2 not found — skip SDDM setup${NC}"
        return 0
    fi
    if [ ! -f "$our_conf" ]; then
        echo -e "${YELLOW}[Warn] Missing $our_conf — skip SDDM setup${NC}"
        return 0
    fi

    echo -e "\n${CYAN}Configuring SDDM...${NC}"
    if [ -f "$bg_src" ]; then
        sudo cp -f "$bg_src" "$bg_dst"
    fi
    if [ -f "$theme_conf" ] && [ ! -f "${theme_conf}.dotfiles-bak" ]; then
        sudo cp -f "$theme_conf" "${theme_conf}.dotfiles-bak"
    fi
    sudo cp -f "$our_conf" "$theme_conf"
    echo -e "${GREEN}[OK] SDDM theme.conf applied${NC}"
}

setup_chrome() {
    echo -e "\n${CYAN}Chrome Wayland flags / stale locks...${NC}"
    if ! pgrep -x chrome >/dev/null 2>&1 && ! pgrep -f '/opt/google/chrome/chrome' >/dev/null 2>&1; then
        for f in SingletonLock SingletonCookie SingletonSocket; do
            if [ -e "$HOME/.config/google-chrome/$f" ]; then
                rm -f "$HOME/.config/google-chrome/$f"
            fi
        done
    else
        echo -e "${YELLOW}[Warn] Chrome is running — skip Singleton cleanup${NC}"
    fi
}

enable_services() {
    echo -e "\n${CYAN}Enabling user services...${NC}"
    systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || true
    systemctl --user enable hyprpolkitagent.service 2>/dev/null || true
    sudo systemctl enable --now bluetooth.service 2>/dev/null || true
}

apply_live_session() {
    [ -n "${WAYLAND_DISPLAY:-}" ] || return 0
    echo -e "\n${CYAN}Hyprland session detected — applying wallpaper...${NC}"
    bash "$DOTFILES_DIR/.config/hypr/scripts/set-wallpaper.sh" random || true
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl reload >/dev/null 2>&1 || true
    fi
    pkill -x waybar 2>/dev/null || true
    if [ -x "$HOME/.local/bin/waybar" ]; then
        "$HOME/.local/bin/waybar" &
        disown || true
    fi
}

sync_links() {
    echo -e "\n${CYAN}Syncing configs to ~/.config and home directory...${NC}\n"

    chmod +x "$DOTFILES_DIR/.config/hypr/scripts/"*.sh 2>/dev/null || true
    chmod +x "$DOTFILES_DIR/scripts/"* 2>/dev/null || true

    link_hypr_tree
    link_file "$DOTFILES_DIR/.config/waybar" "$CONFIG_DIR/waybar" "Waybar"
    link_file "$DOTFILES_DIR/.config/kitty" "$CONFIG_DIR/kitty" "Kitty"
    link_file "$DOTFILES_DIR/.config/rofi" "$CONFIG_DIR/rofi" "Rofi"
    link_file "$DOTFILES_DIR/.config/fuzzel" "$CONFIG_DIR/fuzzel" "Fuzzel"
    link_file "$DOTFILES_DIR/.config/swaync" "$CONFIG_DIR/swaync" "SwayNC"
    link_file "$DOTFILES_DIR/.config/wlogout" "$CONFIG_DIR/wlogout" "Wlogout"
    link_file "$DOTFILES_DIR/.config/btop" "$CONFIG_DIR/btop" "Btop"
    link_file "$DOTFILES_DIR/.config/waypaper" "$CONFIG_DIR/waypaper" "Waypaper"
    link_file "$DOTFILES_DIR/.config/nwg-drawer" "$CONFIG_DIR/nwg-drawer" "Nwg-drawer"
    link_file "$DOTFILES_DIR/.config/gtk-3.0" "$CONFIG_DIR/gtk-3.0" "GTK-3.0"
    link_file "$DOTFILES_DIR/.config/gtk-4.0" "$CONFIG_DIR/gtk-4.0" "GTK-4.0"
    link_file "$DOTFILES_DIR/.config/fish" "$CONFIG_DIR/fish" "Fish"
    link_file "$DOTFILES_DIR/.config/atuin" "$CONFIG_DIR/atuin" "Atuin"
    link_file "$DOTFILES_DIR/.config/quickshell" "$CONFIG_DIR/quickshell" "Quickshell"
    link_file "$DOTFILES_DIR/.config/easyeffects" "$CONFIG_DIR/easyeffects" "EasyEffects"
    link_file "$DOTFILES_DIR/.config/fastfetch" "$CONFIG_DIR/fastfetch" "Fastfetch"
    link_file "$DOTFILES_DIR/.config/chrome-flags.conf" "$CONFIG_DIR/chrome-flags.conf" "Chrome flags"

    if [ -d "$DOTFILES_DIR/.config/zed" ]; then
        link_file "$DOTFILES_DIR/.config/zed" "$CONFIG_DIR/zed" "Zed"
    fi
    if [ -d "$DOTFILES_DIR/.config/mako" ]; then
        link_file "$DOTFILES_DIR/.config/mako" "$CONFIG_DIR/mako" "Mako"
    fi
    if [ -f "$DOTFILES_DIR/.config/starship.toml" ]; then
        link_file "$DOTFILES_DIR/.config/starship.toml" "$CONFIG_DIR/starship.toml" "Starship"
    fi

    link_file "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc" "Zsh RC"
    if [ -f "$DOTFILES_DIR/shell/.bashrc" ]; then
        link_file "$DOTFILES_DIR/shell/.bashrc" "$HOME/.bashrc" "Bash RC"
    fi

    mkdir -p "$HOME/.local/bin"
    link_file "$DOTFILES_DIR/scripts/audio-switch" "$HOME/.local/bin/audio-switch" "Audio output switcher"
    link_file "$DOTFILES_DIR/scripts/battery-saver" "$HOME/.local/bin/battery-saver" "Battery saver controller"
    link_file "$DOTFILES_DIR/scripts/doctor.sh" "$HOME/.local/bin/dotfiles-doctor" "Dotfiles doctor"
    link_file "$DOTFILES_DIR/scripts/hotkey-cheatsheet" "$HOME/.local/bin/hotkey-cheatsheet" "Hotkeys cheat sheet"
    link_file "$DOTFILES_DIR/scripts/host-id" "$HOME/.local/bin/dotfiles-host-id" "Host id resolver"
    link_file "$DOTFILES_DIR/scripts/install-packages.sh" "$HOME/.local/bin/install-dotfiles-packages" "Package installer"
    link_file "$DOTFILES_DIR/scripts/network-menu" "$HOME/.local/bin/network-menu" "Network menu (Fuzzel)"
    link_file "$DOTFILES_DIR/scripts/ocr-snip" "$HOME/.local/bin/ocr-snip" "OCR screenshot helper"
    link_file "$DOTFILES_DIR/scripts/powermenu" "$HOME/.local/bin/powermenu" "Power menu (Fuzzel)"
    link_file "$DOTFILES_DIR/scripts/setup-dev-tools.sh" "$HOME/.local/bin/setup-dev-tools" "Developer tool setup"
    link_file "$DOTFILES_DIR/scripts/smart-snip" "$HOME/.local/bin/smart-snip" "Smart screenshot snip"
    link_file "$DOTFILES_DIR/scripts/theme-switcher.sh" "$HOME/.local/bin/theme-switcher" "Theme switcher"
    link_file "$DOTFILES_DIR/scripts/waybar" "$HOME/.local/bin/waybar" "Waybar watchdog wrapper"
    link_file "$DOTFILES_DIR/scripts/waybar-fan" "$HOME/.local/bin/waybar-fan" "Power profile & fan controller"

    link_host_layer

    if [ -d "$BACKUP_DIR" ]; then
        echo -e "\n${YELLOW}Existing configs were backed up to: ${BACKUP_DIR}${NC}"
    fi
}

run_extras() {
    setup_wallpapers
    setup_lock_bg
    setup_sddm
    setup_chrome
    enable_services
    apply_live_session
}

main() {
    print_banner

    if [ "${1:-}" = "--host" ] || [ "${1:-}" = "-H" ]; then
        [ $# -ge 2 ] || {
            echo -e "${RED}--host needs an id${NC}"
            exit 1
        }
        HOST_ID_OVERRIDE="$2"
        "$DOTFILES_DIR/scripts/host-id" --pin "$HOST_ID_OVERRIDE"
        shift 2
    fi

    local action="${1:-link}"
    shift || true

    case "$action" in
        -h | --help | help)
            show_help
            exit 0
            ;;
        -a | --all | all)
            build_helpers
            if [ $# -eq 0 ]; then
                install_packages core desktop aur
            else
                install_packages "$@"
            fi
            setup_zsh_plugins
            sync_links
            run_extras
            ;;
        -p | --packages | packages)
            if [ $# -eq 0 ]; then
                install_packages core desktop aur
            else
                install_packages "$@"
            fi
            ;;
        -z | --zsh | zsh)
            setup_zsh_plugins
            ;;
        -b | --build | build)
            build_helpers
            ;;
        -d | --dev | dev)
            setup_dev
            ;;
        -l | --link | link | "")
            build_helpers
            sync_links
            run_extras
            ;;
        --fix-hypr | fix-hypr)
            link_hypr_tree
            ;;
        *)
            echo -e "${RED}Unknown option: $action${NC}\n"
            show_help
            exit 1
            ;;
    esac

    echo -e "\n${GREEN}============================================================${NC}"
    echo -e "${GREEN} Setup completed successfully!                             ${NC}"
    echo -e "${GREEN}============================================================${NC}"
    echo "Pin this laptop with: ./install.sh --host home-msi-gf63"
}

main "$@"
