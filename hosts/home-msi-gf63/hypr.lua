-- Host layer: MSI GF63 Thin 11UC (Intel + NVIDIA hybrid)
--
-- Loaded by .config/hypr/hyprland.lua via require("hosts.home-msi-gf63.hypr").
-- Pin with: ./install.sh --host home-msi-gf63

-- Ten workspaces match Super+1..0 from the daily keymap.
WORKSPACE_COUNT = 10

------------------
---- MONITORS ----
------------------

-- Built-in 144Hz panel. "auto-right" keeps it to the right of an HDMI monitor
-- and still lands at 0x0 when the laptop runs on its own.
hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@144",
    position = "auto-right",
    scale = 1,
})

-- Fallback for HDMI / projector (connector name can change; Hyprland places it).
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})
