-- Host layer template. Copy this directory to hosts/<your-host-id> and edit.
--
--   ./scripts/host-id --detect      show the auto-derived id for this machine
--   ./install.sh --host office      pin a friendlier id and link the layer
--
-- Loaded by .config/hypr/hyprland.lua via require("hosts.<id>.hypr").
-- Put everything tied to this physical laptop here: panel modes, monitor
-- descriptions, workspace count. The shared config must stay hardware-free.

-- How many workspaces exist and how many number keys are bound.
-- Must match "persistent-workspaces" in this directory's waybar.jsonc.
WORKSPACE_COUNT = 5

------------------
---- MONITORS ----
------------------

-- Run `hyprctl monitors` on the machine and fill these in. Prefer
-- `desc:<description>` over a connector name like HDMI-A-1: the connector
-- changes with which port you plug into, the description does not.

-- hl.monitor({
--     output   = "desc:Dell Inc. U2422H XXXXXXX",
--     mode     = "1920x1080@60",
--     position = "0x0",
--     scale    = 1,
-- })

-- Built-in panel. "auto-right" keeps it right of any external monitor and
-- still lands at 0x0 when the laptop runs on its own.
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "auto-right",
    scale    = 1,
})

-- Fallback for any other external monitor or projector.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})
