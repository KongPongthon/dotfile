# Theme palettes

Color source of truth is `.config/themes/palettes/` (one `KEY=hex` file per palette). `theme-switcher` fills `.config/themes/templates/` and writes the active app files.

## Palettes

Same Rumda canvas (espresso / warm sand). Only the accent changes.

| Id | Name | Accent |
| :--- | :--- | :--- |
| `rumda-dark` / `rumda-light` | Rumda | Purple `#817BBE` / `#6E64A6` |
| `tide-dark` / `tide-light` | Tide | Cyan `#6C9BA8` / `#2D7B8C` |
| `ember-dark` / `ember-light` | Ember | Terracotta `#D89371` / `#C57434` |
| `moss-dark` / `moss-light` | Moss | Sage `#5B8F64` / `#497E54` |

## How to switch

- `SUPER+SHIFT+T` — Fuzzel menu of all palettes
- `SUPER+SHIFT+W` — Fuzzel menu of wallpapers (`Random` is the first row)
- CLI: `theme pick`, `theme apply tide-dark`, `theme toggle` (dark ↔ light of the current family), `theme list`, `theme status`

`~/.config/current_theme` stores the id (`rumda-dark`, …). Legacy values `dark` / `light` map to Rumda.

## How to edit colors and fonts

Edit a palette file, then `theme apply <id>` (or pick it from the menu). Do not treat generated files as the source.

### Colors

- Palettes: `.config/themes/palettes/*.conf`
- Templates: `.config/themes/templates/`
- Generated (overwritten on apply): Waybar `colors.css`, Kitty `current-theme.conf`, Fuzzel `fuzzel.ini`, Mako `config`, GTK `gtk-current.css`, Starship `starship.toml`, Btop `themes/current.theme`, nwg-drawer `drawer.css`, Rofi `colors.rasi`, Hyprlock `hyprlock-colors.conf`, `~/.config/current_palette.json`

Hyprland border colors in `hyprland.lua` are the boot default. `theme-switcher restore` runs on login / Hyprland reload so the saved palette wins.

### Fonts

- Waybar: `font-family` / `font-size` in `.config/waybar/style.css` (layout only; colors stay in `colors.css`)
- Kitty: `font_family` / `font_size` in `.config/kitty/kitty.conf`
- Fuzzel: the `font=` line in `.config/themes/templates/fuzzel.ini.tmpl`

After Waybar layout edits: `pkill -SIGUSR2 -x waybar`. After palette edits: `theme apply <id>`.
