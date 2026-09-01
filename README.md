# Personal minimal Hyprland dotfiles

Lightweight Hyprland setup for Arch/CachyOS (MSI GF63: Intel + NVIDIA).
Independent of JaKooLit / wallust / quickshell / cava.

## Includes

- Hyprland + hypridle/hyprlock (`hyprpolkitagent` via systemd user service)
- kitty, waybar, rofi, swaync, wlogout, awww (swww successor)
- Waybar with date/time, weather, CPU, RAM, temperature, brightness, mpris, notifications
- zsh + Oh-My-Zsh + pokemon-colorscripts
- google-chrome + cursor-bin (Chrome flags for Wayland; does **not** change default browser)
- Pipewire, portals, bluetooth, gnome-keyring, lm_sensors, Papirus icons
- SDDM login theme tweaks (centered user/password + wallpaper)

## Not included (on purpose)

- JaKooLit / KooL full dots, quickshell, wallust
- cava (audio visualizer — pretty but continuous CPU; not useful for monitoring)
- ASUS ROG tools (this machine is MSI)
- Thunar, heavy theme packs, extra fonts

## Install

```bash
cd ~/dotfiles
chmod +x install.sh shell/omz-setup.sh config/hypr/scripts/*.sh config/waybar/scripts/*.sh
./install.sh
```

Then log out and start Hyprland again. Existing configs are backed up under `~/.dotfiles-backup-*`.
Reboot (or restart SDDM) to see the login screen changes.

## Login vs Lock

| When | Component | Behavior |
|------|-----------|----------|
| Boot / logout | **SDDM** (`simple_sddm_2`) | Wallpaper background; username + password **centered**. Does not change Autologin settings. |
| In session | **hyprlock** + **hypridle** | Wallpaper via `~/.config/hypr/lock.bg`; user + password centered. |

### Lock

- `Super+L` or waybar lock → **hyprlock** (clock + password) immediately
- Lid close → lock, then **DPMS off** (screen blanks like sleep)
- Idle ~5 min → lock; ~10s later → DPMS off
- Mouse move or key press → screen on again with the unlock UI
- Changing wallpaper (`Super+Shift+W`) also updates `lock.bg` for the next lock

## Keybinds

| Key | Action |
|-----|--------|
| Super+Return | kitty |
| Super+B | Google Chrome |
| Super+C | Cursor |
| Super+Space | rofi |
| Super+N | SwayNC notification center |
| Super+E | open home |
| Super+L | lock (hyprlock) |
| Super+arrows / H J K ; | move focus |
| Super+, / Super+. | previous / next workspace |
| Super+Shift+, / Super+Shift+. | same (`<` / `>`) |
| Super+Shift+W | random wallpaper |
| Print | screenshot region → clipboard |

## Waybar

- Center: weather + clock (`วัน เดือน ปี` + เวลา; locale `th_TH.UTF-8`)
- Right: CPU %, RAM %, package temp (`thermal_zone` x86_pkg_temp), brightness, audio, network, battery, mpris, idle inhibitor, notifications, tray, lock, power
- Weather script: `~/.config/waybar/scripts/weather.sh` (wttr.in, cached 30m). Override location with `WEATHER_LOC=Bangkok` in the environment if needed.

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

## Private git

```bash
cd ~/dotfiles
git remote add origin git@github.com:YOU/dotfiles.git
git push -u origin main
```
