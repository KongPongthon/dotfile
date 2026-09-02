# Hyprland dotfiles

Personal Hyprland setup for Arch/CachyOS (MSI GF63: Intel + NVIDIA).

## Includes

- Hyprland + hypridle / hyprlock (`hyprpolkitagent` via systemd user service)
- kitty, rofi, swaync, wlogout, awww
- zsh + Oh-My-Zsh + pokemon-colorscripts
- google-chrome + cursor-bin (Chrome flags for Wayland; does **not** change default browser)
- Pipewire, portals, bluetooth, gnome-keyring, Papirus icons
- SDDM login theme tweaks (centered user/password + wallpaper)

No status bar yet — use keybinds below.

## Install

```bash
cd ~/dotfiles
chmod +x install.sh shell/omz-setup.sh config/hypr/scripts/*.sh
./install.sh
```

Then log out and start Hyprland again. Existing configs are backed up under `~/.dotfiles-backup-*`.
Reboot (or restart SDDM) to see the login screen changes.

## Login vs Lock

| When | Component | Behavior |
|------|-----------|----------|
| Boot / logout | **SDDM** (`simple_sddm_2`) | Wallpaper background; username + password **centered**. Does not change Autologin settings. |
| In session | **hyprlock** + **hypridle** | Wallpaper via `~/.config/hypr/lock.bg`; user + password centered. |

- `Super+L` → **hyprlock** immediately
- Lid close → lock, then **DPMS off**
- Idle ~5 min → lock; ~10s later → DPMS off
- Mouse move or key press → screen on again with the unlock UI
- `Super+Shift+W` also updates `lock.bg` for the next lock

## Keybinds

| Key | Action |
|-----|--------|
| Super+Return | kitty |
| Super+B | Google Chrome |
| Super+C | Cursor |
| Super+D | rofi |
| Super+E | open home |
| Super+Q | close window |
| Super+M | logout menu (wlogout) |
| Super+V | clipboard (cliphist + rofi) |
| Super+L | lock (hyprlock) |
| Super+N | notification center |
| Super+F | fullscreen |
| Super+T | toggle floating |
| Super+arrows / H J K ; | move focus |
| Super+Shift+arrows / H K ; | move window |
| Super+1 … 0 | workspace |
| Super+Shift+1 … 0 | send to workspace |
| Super+, / Super+. | previous / next workspace |
| Super+Shift+W | random wallpaper |
| Print | screenshot region → clipboard |
| Super+Print | screenshot full screen → clipboard |

Volume, mute, play/pause, brightness: hardware keys.

## Wallpapers

Runtime order:

1. `~/รูปภาพ/wallpapers`
2. `~/Pictures/wallpapers`
3. `~/dotfiles/wallpapers` (starter set in this repo)

Uses **awww** (with swww fallback). SDDM default background install uses `wallpapers/Night monochrome.jpg`.

## Chrome on hybrid NVIDIA

- `~/.config/chrome-flags.conf` uses Ozone Wayland hint
- Global `LIBVA_DRIVER_NAME=nvidia` is **not** forced (see `config/hypr/env.conf`)
- `install.sh` clears stale Chrome Singleton locks when Chrome is not running
- Default browser is **left unchanged** (e.g. Zen stays default); Super+B still opens Chrome
