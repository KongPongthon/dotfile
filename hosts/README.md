# Host layers

This tree currently ships `hosts/home-msi-gf63/` for the MSI GF63 Thin 11UC
(Intel + NVIDIA). Pin it with:

```sh
./install.sh --host home-msi-gf63
```

The DMI slug `micro-star-international-co-ltd-gf63-thin-11uc` is a symlink to
that directory so a fresh clone still resolves before pinning.

Everything under `hosts/<id>/` belongs to one physical machine. The shared
config in `.config/` must never name a panel, a refresh rate, a monitor
description, or a `/sys` sensor path — those live here instead, so the same
branch runs on every laptop without merge conflicts.

## Resolving the id

`scripts/host-id` decides which directory is used, first hit wins:

| Source | Purpose |
| --- | --- |
| `$DOTFILES_HOST` | one-off override, useful for testing another layer |
| `~/.config/dotfiles-host` | the pinned alias, written by `install.sh --host` |
| DMI vendor + model slug | so a fresh clone works before anything is pinned |
| hostname | last resort if DMI is unreadable |

```sh
./scripts/host-id            # what will be used
./scripts/host-id --detect   # the DMI slug, ignoring any pinned alias
```

## Adding a machine

```sh
git clone <repo> ~/dotfiles && cd ~/dotfiles
cp -r hosts/_template hosts/office
./install.sh --host office        # pins the alias, then links everything
$EDITOR hosts/office/hypr.lua     # fill in from `hyprctl monitors`
$EDITOR hosts/office/waybar.jsonc # fill in the sensor and keyboard names
$EDITOR hosts/office/kanshi
hyprctl reload && pkill -x waybar
```

Commit the new directory. Both machines track `main`; they only ever touch
their own `hosts/` subdirectory, so pulling never conflicts.

## What each file does

| File | Consumed by | How |
| --- | --- | --- |
| `hypr.lua` | `.config/hypr/hyprland.lua` | `require("hosts.<id>.hypr")` through the `.config/hypr/hosts` symlink |
| `waybar.jsonc` | `.config/waybar/config.jsonc` | `"include"` of `~/.config/waybar/host.jsonc`, symlinked by `install.sh` |
| `kanshi` | kanshi | symlinked to `~/.config/kanshi/config` by `install.sh` |

`hypr.lua` sets the global `WORKSPACE_COUNT`, which the shared config reads to
create workspace rules and bind the number keys. Keep it in sync with
`persistent-workspaces` in the same directory's `waybar.jsonc`.

Machine-local files that are *not* shared (`~/.config/dotfiles-host`, the
`host.jsonc` and `kanshi/config` symlinks) are gitignored.
