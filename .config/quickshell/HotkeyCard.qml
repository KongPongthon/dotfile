import QtQuick
import QtQuick.Layouts

Rectangle {
    id: hotkeyCard

    property var itemData: ({})
    property var theme

    implicitHeight: 64
    radius: 10
    color: mouseArea.containsMouse ? (theme ? theme.bgCardHover : "#3D3027") : (theme ? theme.bgCard : "#2D231C")
    border.width: 1
    border.color: mouseArea.containsMouse ? (theme ? theme.borderActive : "#9890D0") : (theme ? theme.borderCard : "#3D3128")

    Behavior on color {
        ColorAnimation { duration: 120 }
    }
    Behavior on border.color {
        ColorAnimation { duration: 120 }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: 12

        // Left Column: Category tag, Title & Description
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 3

            RowLayout {
                spacing: 8

                // Title
                Text {
                    text: hotkeyCard.itemData.title || ""
                    font.family: "Sans-Serif, Inter, sans-serif"
                    font.pixelSize: 13
                    font.bold: true
                    color: hotkeyCard.theme ? hotkeyCard.theme.fgPrimary : "#E9F3FB"
                    elide: Text.ElideRight
                }

                // Category pill tag
                Rectangle {
                    implicitWidth: catLabel.implicitWidth + 10
                    implicitHeight: 18
                    radius: 9
                    color: {
                        var cat = hotkeyCard.itemData.category;
                        if (cat === "apps") return hotkeyCard.theme ? hotkeyCard.theme.accentPurpleLight : "#9890D0";
                        if (cat === "windows") return hotkeyCard.theme ? hotkeyCard.theme.accentBlue : "#9CADCF";
                        if (cat === "workspaces") return hotkeyCard.theme ? hotkeyCard.theme.accentCyan : "#9AC2CB";
                        if (cat === "tools") return hotkeyCard.theme ? hotkeyCard.theme.statusGreen : "#98C379";
                        return hotkeyCard.theme ? hotkeyCard.theme.accentPurple : "#817BBE";
                    }
                    opacity: 0.25

                    Text {
                        id: catLabel
                        anchors.centerIn: parent
                        text: {
                            var cat = hotkeyCard.itemData.category;
                            if (cat === "apps") return "Apps";
                            if (cat === "windows") return "Window";
                            if (cat === "workspaces") return "Workspace";
                            if (cat === "tools") return "Tools";
                            if (cat === "system") return "System";
                            return cat || "";
                        }
                        font.family: "Sans-Serif"
                        font.pixelSize: 10
                        font.bold: true
                        color: hotkeyCard.theme ? hotkeyCard.theme.fgPrimary : "#E9F3FB"
                    }
                }
            }

            // Description
            Text {
                Layout.fillWidth: true
                text: hotkeyCard.itemData.desc || ""
                font.family: "Sans-Serif, Inter, sans-serif"
                font.pixelSize: 11
                color: hotkeyCard.theme ? hotkeyCard.theme.fgMuted : "#9CADCF"
                elide: Text.ElideRight
            }
        }

        // Right Column: Key sequence
        Row {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            spacing: 4

            Repeater {
                model: hotkeyCard.itemData.keys || []

                Row {
                    spacing: 4

                    KeyBadge {
                        keyText: modelData
                        theme: hotkeyCard.theme
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        visible: index < (hotkeyCard.itemData.keys.length - 1)
                        text: "+"
                        font.family: "JetBrains Mono, monospace"
                        font.pixelSize: 12
                        font.bold: true
                        color: hotkeyCard.theme ? hotkeyCard.theme.fgMuted : "#9CADCF"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
