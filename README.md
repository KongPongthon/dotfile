# Hyprland dotfiles

Personal Hyprland setup for Arch/CachyOS on **MSI GF63 Thin 11UC** (Intel + NVIDIA). Architecture follows a testdot-style Lua config, host layers, and helper scripts. Daily keybinds stay the previous `keybinds.conf` map, rewritten as Lua.

## Includes

- Hyprland Lua (`hyprland.lua`) + hypridle / hyprlock (`hyprpolkitagent`)
- kitty, waybar, fuzzel, swaync, wlogout, awww
- zsh + Oh-My-Zsh + Starship + pokemon-colorscripts
- google-chrome + cursor-bin (Chrome flags for Wayland; does **not** change default browser)
- PipeWire, portals, bluetooth, gnome-keyring, Papirus icons
- SDDM login theme tweaks (centered user/password + wallpaper)
- Rumda dark/light theme switcher (`theme toggle`)

## Install

```bash
cd ~/dotfiles
chmod +x install.sh
./install.sh --host home-msi-gf63 --all
```

Or link only (after packages exist):

```bash
./install.sh --host home-msi-gf63 --link
```

Then log out and start Hyprland again. Existing configs are backed up under `~/.dotfiles-backup-*`.
Reboot (or restart SDDM) to see the login screen changes.

`hosts/home-msi-gf63` holds this laptop's monitors, Waybar sensors, and kanshi profiles. The DMI slug is a symlink to that directory so a fresh clone still resolves.

## NVIDIA hybrid

Do **not** force `LIBVA_DRIVER_NAME=nvidia` or `__GLX_VENDOR_LIBRARY_NAME=nvidia` globally — that often breaks Chrome GPU / VAAPI. UI apps stay on Intel. `~/.config/chrome-flags.conf` uses Ozone Wayland.

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

Daily map (same keys as before):

| Key | Action |
|-----|--------|
| Super+Return | kitty |
| Super+B | Google Chrome |
| Super+C | Cursor |
| Super+D | launcher (Fuzzel) |
| Super+E | open home |
| Super+Q | close window |
| Super+M | logout menu (wlogout) |
| Super+V | clipboard (cliphist + Fuzzel) |
| Super+L | lock (hyprlock) |
| Super+N | notification center (swaync) |
| Super+F | fullscreen |
| Super+T | toggle floating |
| Super+P | pseudo |
| Super+Shift+J | toggle dwindle split |
| Super+H J K ; | move focus |
| Super+arrows / Super+Shift+arrows / H K ; | move window |
| Super+1 … 0 | workspace |
| Super+Shift+1 … 0 | send to workspace |
| Super+, / Super+. | previous / next workspace |
| Super+Shift+W | random wallpaper |
| Print | screenshot region → clipboard |
| Super+Print | screenshot full screen → clipboard |

Volume, mute, play/pause, brightness: hardware keys.

Extras on unused keys:

| Key | Action |
|-----|--------|
| Super+/ | hotkey cheat sheet |
| Super+Shift+S | smart-snip (copy / swappy) |
| Super+Shift+X | OCR Thai+English |
| Super+F10 | audio output switcher |
| Super+Shift+T | toggle Rumda dark/light |
| Super+Shift+C | color picker |
| Super+Shift+E | yazi |
| Ctrl+Super+B | battery saver |
| Ctrl+Super+R | reload Hyprland and Waybar |

## Wallpapers

Runtime order:

1. `~/รูปภาพ/wallpapers`
2. `~/Pictures/wallpapers`
3. `~/dotfiles/wallpapers` (starter set in this repo)

Uses **awww** (with swww fallback). SDDM default background install uses `wallpapers/Night monochrome.jpg`.

## Chrome on hybrid NVIDIA

- `~/.config/chrome-flags.conf` uses Ozone Wayland hint
- Global `LIBVA_DRIVER_NAME=nvidia` is **not** forced
- `install.sh` clears stale Chrome Singleton locks when Chrome is not running
- Default browser is **left unchanged**; Super+B still opens Chrome
