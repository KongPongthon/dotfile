import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: theme

    property FileView themeWatcher: FileView {
        path: Quickshell.env("HOME") + "/.config/current_theme"
        watchChanges: true
    }

    property FileView paletteWatcher: FileView {
        path: Quickshell.env("HOME") + "/.config/current_palette.json"
        watchChanges: true
    }

    function parsePalette() {
        var raw = paletteWatcher.text || "";
        if (raw.trim().length === 0)
            return ({});
        try {
            return JSON.parse(raw);
        } catch (e) {
            return ({});
        }
    }

    readonly property var palette: parsePalette()
    readonly property string currentTheme: (palette.id || themeWatcher.text || "rumda-dark").toString().trim()
    readonly property bool isLight: palette.isLight === true || currentTheme === "light" || currentTheme.endsWith("-light")

    function c(key, fallback) {
        var value = palette[key];
        return (value !== undefined && value !== null && value !== "") ? value : fallback;
    }

    // Backgrounds
    readonly property color bgCanvas: c("bgCanvas", isLight ? "#F4EFEA" : "#1C1612")
    readonly property color bgSurface: c("bgSurface", isLight ? "#EFE8E1" : "#241C16")
    readonly property color bgCard: c("bgCard", isLight ? "#FAF6F2" : "#2D231C")
    readonly property color bgCardHover: c("bgCardHover", isLight ? "#E5DDD4" : "#3D3027")
    readonly property color bgInput: c("bgInput", isLight ? "#E5DDD4" : "#1A1410")
    readonly property color bgHover: c("bgHover", isLight ? "#D8CBC0" : "#382C24")

    // Borders
    readonly property color borderSubtle: c("borderSubtle", isLight ? "#C8B9AC" : "#4A3C32")
    readonly property color borderActive: c("borderActive", isLight ? "#8E86C6" : "#9890D0")
    readonly property color borderCard: c("borderCard", isLight ? "#DDD1C5" : "#3D3128")

    // Text & Foregrounds
    readonly property color fgPrimary: c("fgPrimary", isLight ? "#2B2538" : "#E9F3FB")
    readonly property color fgSecondary: c("fgSecondary", isLight ? "#534C64" : "#D0DBE6")
    readonly property color fgMuted: c("fgMuted", isLight ? "#8A8099" : "#9CADCF")

    // Accents
    readonly property color accentPurple: c("accentPurple", isLight ? "#6E64A6" : "#817BBE")
    readonly property color accentPurpleLight: c("accentPurpleLight", isLight ? "#8E86C6" : "#9890D0")
    readonly property color accentBlue: c("accentBlue", isLight ? "#4A6D8C" : "#9CADCF")
    readonly property color accentCyan: c("accentCyan", isLight ? "#2D7B8C" : "#9AC2CB")
    readonly property color statusRed: c("statusRed", isLight ? "#B5483B" : "#E06C75")
    readonly property color statusGreen: c("statusGreen", isLight ? "#497E54" : "#98C379")

    // Keycaps
    readonly property color keycapBg: c("keycapBg", isLight ? "#DFD4C8" : "#382C24")
    readonly property color keycapBorder: c("keycapBorder", isLight ? "#BDB0A3" : "#57473D")
    readonly property color keycapText: c("keycapText", isLight ? "#2B2538" : "#F4EFEA")

    // Keycaps for modifiers (SUPER, CTRL, SHIFT, ALT)
    readonly property color keycapModBg: c("keycapModBg", isLight ? "#D6CFE8" : "#3E3452")
    readonly property color keycapModBorder: c("keycapModBorder", isLight ? "#B2A7D4" : "#655383")
    readonly property color keycapModText: c("keycapModText", isLight ? "#261D3B" : "#EBE4FF")

    // Scrim / Backdrop
    readonly property color scrimColor: c("scrimColor", isLight ? "#6028201A" : "#80000000")
}
