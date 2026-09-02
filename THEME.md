# 🌧️ Theme Palette Reference: Rumda Dark x Rainy Keyboard

Extracted using **HSV Masking + K-Means** and mapped to Rumda's matte dark aesthetic.

---

### 🎨 Color Tokens

| Token | Hex | Element Role |
| :--- | :--- | :--- |
| `bg.canvas` | `#1C1612` | Main matte dark background (Hyprland, Kitty, Rofi window) |
| `bg.surface` | `#28201A` | Card / Module surface (Waybar pills, Mako notification cards, Drawer input) |
| `bg.hover` | `#382C24` | Active selection, hovered modules & buttons |
| `border.subtle`| `#4A3C32` | Inactive dividers and subtle borders |
| `accent.purple_light` | `#9890D0` | Active window border (high), cursor, active search match |
| `accent.purple_base` | `#817BBE` | Active window border (base), active workspace pill, primary accent |
| `accent.purple_dark` | `#66609E` | Secondary dark purple accent |
| `accent.purple_deep` | `#423E63` | Inactive window border, legend ink |
| `fg.white_top` | `#E9F3FB` | Primary text (Alphas keycap top face) |
| `fg.white_shadow` | `#D0DBE6` | Secondary text (Alphas keycap shadow face) |
| `fg.blue_gray` | `#9CADCF` | Icons, title, directory in prompt (Modifier keycap) |
| `fg.blue_shadow` | `#6C769F` | Muted/dim text, inactive tabs |
| `cyan.legend` | `#9AC2CB` | Clock, network, URLs, git status (Legend cyan text) |
| `body.highlight` | `#E7F3FD` | Case shell highlight |
| `body.base` | `#C5D3E0` | Case shell base |

---

## How to edit colors and fonts

`theme-switcher` **copies** theme files over the active ones. Edit the **source** files, then run `theme dark` or `theme light`. Do not treat the copied files as the source of truth.

### Colors (edit dark and light together if you toggle)

- Waybar: `.config/waybar/themes/style-dark.css` and `style-light.css` — the `@define-color` block at the top (`bg`, `fg`, `purple_base`, `cyan`, …)
  - Do not edit `.config/waybar/style.css` as the source; `theme-switcher` overwrites it
- Kitty colors: `.config/kitty/themes/rumda-dark.conf` / `rumda-light.conf`
- Fuzzel: `.config/fuzzel/themes/`
- Hyprland window borders: `general.col.active_border` in `.config/hypr/hyprland.lua`, **and** the `hyprctl keyword general:col.*` lines in `scripts/theme-switcher.sh` (otherwise a theme toggle resets borders to Rumda)

### Fonts

- Waybar: `font-family` / `font-size` in `style-dark.css` and `style-light.css` (currently `"Silkscreen"` with JetBrains / Meslo fallbacks)
- Kitty: `font_family` / `font_size` in `.config/kitty/kitty.conf` (not in the rumda theme files)
- Fuzzel: the `font=` line in the fuzzel theme files

After Waybar CSS changes: `pkill -SIGUSR2 -x waybar`, or run `theme dark` / `theme light` so the source files are copied into `style.css` again.

