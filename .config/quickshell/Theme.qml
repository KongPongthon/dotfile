import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: theme

    property FileView themeWatcher: FileView {
        path: Quickshell.env("HOME") + "/.config/current_theme"
        watchChanges: true
    }

    readonly property string currentTheme: (themeWatcher.text || "dark").trim()
    readonly property bool isLight: currentTheme === "light"

    // Backgrounds
    readonly property color bgCanvas: isLight ? "#F4EFEA" : "#1C1612"
    readonly property color bgSurface: isLight ? "#EFE8E1" : "#241C16"
    readonly property color bgCard: isLight ? "#FAF6F2" : "#2D231C"
    readonly property color bgCardHover: isLight ? "#E5DDD4" : "#3D3027"
    readonly property color bgInput: isLight ? "#E5DDD4" : "#1A1410"
    readonly property color bgHover: isLight ? "#D8CBC0" : "#382C24"

    // Borders
    readonly property color borderSubtle: isLight ? "#C8B9AC" : "#4A3C32"
    readonly property color borderActive: isLight ? "#8E86C6" : "#9890D0"
    readonly property color borderCard: isLight ? "#DDD1C5" : "#3D3128"

    // Text & Foregrounds
    readonly property color fgPrimary: isLight ? "#2B2538" : "#E9F3FB"
    readonly property color fgSecondary: isLight ? "#534C64" : "#D0DBE6"
    readonly property color fgMuted: isLight ? "#8A8099" : "#9CADCF"

    // Accents
    readonly property color accentPurple: isLight ? "#6E64A6" : "#817BBE"
    readonly property color accentPurpleLight: isLight ? "#8E86C6" : "#9890D0"
    readonly property color accentBlue: isLight ? "#4A6D8C" : "#9CADCF"
    readonly property color accentCyan: isLight ? "#2D7B8C" : "#9AC2CB"
    readonly property color statusRed: isLight ? "#B5483B" : "#E06C75"
    readonly property color statusGreen: isLight ? "#497E54" : "#98C379"

    // Keycaps
    readonly property color keycapBg: isLight ? "#DFD4C8" : "#382C24"
    readonly property color keycapBorder: isLight ? "#BDB0A3" : "#57473D"
    readonly property color keycapText: isLight ? "#2B2538" : "#F4EFEA"

    // Keycaps for modifiers (SUPER, CTRL, SHIFT, ALT)
    readonly property color keycapModBg: isLight ? "#D6CFE8" : "#3E3452"
    readonly property color keycapModBorder: isLight ? "#B2A7D4" : "#655383"
    readonly property color keycapModText: isLight ? "#261D3B" : "#EBE4FF"

    // Scrim / Backdrop
    readonly property color scrimColor: isLight ? "#6028201A" : "#80000000"
}
