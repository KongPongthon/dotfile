#!/usr/bin/env bash
# Minimal personal Hyprland dotfiles installer
# Repo: ~/dotfiles
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
PACMAN_LIST="$ROOT/packages/pacman.txt"
AUR_LIST="$ROOT/packages/aur.txt"

ok() { printf '[\e[32mOK\e[0m] %s\n' "$*"; }
note() { printf '[\e[34m..\e[0m] %s\n' "$*"; }
warn() { printf '[\e[33m!!\e[0m] %s\n' "$*"; }
err() { printf '[\e[31mERR\e[0m] %s\n' "$*" >&2; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "Missing command: $1"; exit 1; }
}

aur_helper() {
  if command -v paru >/dev/null 2>&1; then echo paru
  elif command -v yay >/dev/null 2>&1; then echo yay
  else
    err "Need paru or yay for AUR packages"
    exit 1
  fi
}

read_pkgs() {
  local file="$1"
  grep -vE '^\s*(#|$)' "$file" | tr -s ' ' | sed 's/[[:space:]]*$//'
}

install_pacman() {
  note "Installing pacman packages..."
  mapfile -t pkgs < <(read_pkgs "$PACMAN_LIST")
  sudo pacman -S --needed --noconfirm "${pkgs[@]}"
  ok "pacman packages installed"
}

install_aur() {
  local helper
  helper="$(aur_helper)"
  note "Installing AUR packages with $helper..."
  mapfile -t pkgs < <(read_pkgs "$AUR_LIST")
  "$helper" -S --needed --noconfirm "${pkgs[@]}"
  ok "AUR packages installed"
}

backup_then_link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/"
    note "Backed up $dest -> $BACKUP_DIR/"
  fi
  ln -sfn "$src" "$dest"
  ok "Linked $dest -> $src"
}

link_configs() {
  note "Linking configs..."
  backup_then_link "$ROOT/config/hypr" "$HOME/.config/hypr"
  backup_then_link "$ROOT/config/rofi" "$HOME/.config/rofi"
  backup_then_link "$ROOT/config/swaync" "$HOME/.config/swaync"
  backup_then_link "$ROOT/config/kitty" "$HOME/.config/kitty"
  backup_then_link "$ROOT/config/chrome-flags.conf" "$HOME/.config/chrome-flags.conf"
  backup_then_link "$ROOT/config/fastfetch" "$HOME/.config/fastfetch"
  backup_then_link "$ROOT/config/wlogout" "$HOME/.config/wlogout"
  backup_then_link "$ROOT/shell/.zshrc" "$HOME/.zshrc"
  chmod +x "$ROOT/config/hypr/scripts/"*.sh
  ok "Configs linked (backup: $BACKUP_DIR)"
}

setup_wallpapers() {
  local dest="$HOME/รูปภาพ/wallpapers"
  mkdir -p "$HOME/รูปภาพ" "$HOME/Pictures"
  if [[ ! -d "$dest" ]]; then
    mkdir -p "$dest"
    if [[ -d "$ROOT/wallpapers" ]]; then
      cp -a "$ROOT/wallpapers/." "$dest/"
      ok "Seeded wallpapers into $dest"
    fi
  else
    note "Wallpaper dir exists: $dest (keeping your collection)"
  fi
  # Convenience symlink for English path users
  if [[ ! -e "$HOME/Pictures/wallpapers" ]]; then
    ln -sfn "$dest" "$HOME/Pictures/wallpapers" 2>/dev/null || true
  fi
}

setup_lock_bg() {
  note "Setting hyprlock wallpaper symlink..."
  local lock_bg="$HOME/.config/hypr/lock.bg"
  local candidates=(
    "$HOME/รูปภาพ/wallpapers/Night monochrome.jpg"
    "$ROOT/wallpapers/Night monochrome.jpg"
    "$HOME/Pictures/wallpapers/Night monochrome.jpg"
  )
  local img=""
  local c
  for c in "${candidates[@]}"; do
    if [[ -f "$c" ]]; then
      img="$c"
      break
    fi
  done
  if [[ -z "$img" ]]; then
    # Fallback: first image in wallpaper dirs
    for d in "$HOME/รูปภาพ/wallpapers" "$ROOT/wallpapers" "$HOME/Pictures/wallpapers"; do
      [[ -d "$d" ]] || continue
      img="$(find "$d" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) ! -path '*/Dynamic-Wallpapers/*' | head -n1 || true)"
      [[ -n "$img" ]] && break
    done
  fi
  if [[ -n "$img" ]]; then
    mkdir -p "$(dirname "$lock_bg")"
    ln -sfn "$img" "$lock_bg"
    ok "lock.bg -> $img"
  else
    warn "No wallpaper found for lock.bg"
  fi
}

setup_sddm() {
  local theme_dir="/usr/share/sddm/themes/simple_sddm_2"
  local theme_conf="$theme_dir/theme.conf"
  local bg_src="$ROOT/wallpapers/Night monochrome.jpg"
  local bg_dst="$theme_dir/Backgrounds/dotfiles-bg.jpg"
  local our_conf="$ROOT/config/sddm/theme.conf"

  if [[ ! -d "$theme_dir" ]]; then
    warn "SDDM theme simple_sddm_2 not found — skip SDDM setup"
    return 0
  fi
  if [[ ! -f "$our_conf" ]]; then
    warn "Missing $our_conf — skip SDDM setup"
    return 0
  fi

  note "Configuring SDDM (centered form + wallpaper)..."
  if [[ -f "$bg_src" ]]; then
    sudo cp -f "$bg_src" "$bg_dst"
    ok "Installed SDDM background"
  else
    warn "Wallpaper missing: $bg_src"
  fi

  if [[ -f "$theme_conf" && ! -f "${theme_conf}.dotfiles-bak" ]]; then
    sudo cp -f "$theme_conf" "${theme_conf}.dotfiles-bak"
    note "Backed up theme.conf -> theme.conf.dotfiles-bak"
  fi
  sudo cp -f "$our_conf" "$theme_conf"
  ok "SDDM theme.conf applied (FormPosition=center)"

  # Keep theme selection; do not touch Autologin
  if [[ -f /etc/sddm.conf ]]; then
    if ! grep -q 'Current=simple_sddm_2' /etc/sddm.conf 2>/dev/null; then
      warn "Ensure SDDM theme Current=simple_sddm_2 in /etc/sddm.conf"
    fi
  fi
}

setup_shell() {
  note "Setting up Oh-My-Zsh..."
  bash "$ROOT/shell/omz-setup.sh"
  if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
    note "Changing default shell to zsh (may ask password)..."
    chsh -s "$(command -v zsh)" || warn "chsh failed — run: chsh -s $(command -v zsh)"
  fi
  ok "zsh ready"
}

setup_chrome() {
  note "Chrome Wayland flags / stale locks..."
  # Clear stale singleton locks if Chrome is not running
  if ! pgrep -x chrome >/dev/null 2>&1 && ! pgrep -f '/opt/google/chrome/chrome' >/dev/null 2>&1; then
    for f in SingletonLock SingletonCookie SingletonSocket; do
      if [[ -e "$HOME/.config/google-chrome/$f" ]]; then
        rm -f "$HOME/.config/google-chrome/$f"
        note "Removed stale $f"
      fi
    done
  else
    warn "Chrome is running — skip Singleton cleanup"
  fi
  # Do NOT change the default browser (preserve Zen / whatever you use).
  # Super+B still launches google-chrome-stable via Hyprland keybinds.
  ok "Chrome flags linked; default browser left unchanged"
}

enable_services() {
  note "Enabling user services..."
  systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || true
  systemctl --user enable hyprpolkitagent.service 2>/dev/null || true
  sudo systemctl enable --now bluetooth.service 2>/dev/null || true
  ok "Services enabled where possible"
}

apply_live_session() {
  [[ -n "${WAYLAND_DISPLAY:-}" ]] || return 0
  note "Hyprland session detected — applying wallpaper..."
  bash "$ROOT/config/hypr/scripts/set-wallpaper.sh" random || warn "Wallpaper apply failed"
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
  fi
  if pgrep -x waybar >/dev/null 2>&1; then
    pkill -x waybar || true
  fi
  ok "Live session refreshed"
}

main() {
  need_cmd sudo
  need_cmd pacman
  echo "=== Minimal Hyprland dotfiles installer ==="
  echo "Root: $ROOT"
  install_pacman
  install_aur
  setup_wallpapers
  link_configs
  setup_lock_bg
  setup_sddm
  setup_shell
  setup_chrome
  enable_services
  apply_live_session
  echo
  ok "Done. Log out / relaunch Hyprland to apply. Reboot to see SDDM login changes."
  echo "Keybinds: Super+Return kitty | Super+B Chrome | Super+C Cursor | Super+D rofi | Super+N notifications | Super+L lock | Super+,/. workspaces | Super+Shift+W wallpaper"
}

main "$@"
