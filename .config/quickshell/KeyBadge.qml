import QtQuick
import QtQuick.Layouts

Rectangle {
    id: keyBadge

    property string keyText: ""
    property var theme

    readonly property bool isModifier: {
        var k = keyBadge.keyText.toUpperCase();
        return k === "SUPER" || k === "CTRL" || k === "SHIFT" || k === "ALT" || k === "WIN";
    }

    implicitWidth: keyLabel.implicitWidth + 16
    implicitHeight: Math.max(26, keyLabel.implicitHeight + 8)

    radius: 6
    color: isModifier ? (theme ? theme.keycapModBg : "#3E3452") : (theme ? theme.keycapBg : "#382C24")
    border.width: 1
    border.color: isModifier ? (theme ? theme.keycapModBorder : "#655383") : (theme ? theme.keycapBorder : "#57473D")

    // Subtle bottom edge bevel to simulate mechanical keycap
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 2
        radius: 6
        color: keyBadge.isModifier ? (keyBadge.theme ? keyBadge.theme.keycapModBorder : "#504168") : (keyBadge.theme ? keyBadge.theme.keycapBorder : "#42342B")
        opacity: 0.8
    }

    Text {
        id: keyLabel
        anchors.centerIn: parent
        text: keyBadge.keyText
        font.family: "JetBrains Mono, monospace"
        font.pixelSize: 11
        font.bold: true
        color: keyBadge.isModifier ? (keyBadge.theme ? keyBadge.theme.keycapModText : "#EBE4FF") : (keyBadge.theme ? keyBadge.theme.keycapText : "#F4EFEA")
    }
}
