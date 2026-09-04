import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    Theme {
        id: theme
    }

    // Comprehensive Hotkeys Data Catalog
    readonly property var allHotkeys: [
        { "category": "apps", "title": "Terminal", "desc": "เปิด Kitty", "keys": ["SUPER", "Return"], "action": "kitty" },
        { "category": "apps", "title": "Browser", "desc": "เปิด Google Chrome", "keys": ["SUPER", "B"], "action": "google-chrome-stable" },
        { "category": "apps", "title": "Code Editor", "desc": "เปิด Cursor", "keys": ["SUPER", "C"], "action": "cursor" },
        { "category": "apps", "title": "Application Launcher", "desc": "เปิดเมนูโปรแกรม (Fuzzel)", "keys": ["SUPER", "D"], "action": "fuzzel" },
        { "category": "apps", "title": "Home Folder", "desc": "เปิดโฟลเดอร์บ้าน", "keys": ["SUPER", "E"], "action": "xdg-open ~" },
        { "category": "apps", "title": "Yazi File Manager", "desc": "เปิด Yazi ใน Kitty", "keys": ["SUPER", "SHIFT", "E"], "action": "kitty -e yazi" },
        { "category": "apps", "title": "Volume Mixer", "desc": "เปิด Pavucontrol", "keys": ["CTRL", "SUPER", "V"], "action": "pavucontrol" },
        { "category": "apps", "title": "Task Manager", "desc": "เปิด Btop", "keys": ["CTRL", "SHIFT", "Escape"], "action": "btop" },

        { "category": "windows", "title": "Close Window", "desc": "ปิดหน้าต่างที่โฟกัส", "keys": ["SUPER", "Q"], "action": "" },
        { "category": "windows", "title": "Toggle Fullscreen", "desc": "สลับเต็มหน้าจอ", "keys": ["SUPER", "F"], "action": "" },
        { "category": "windows", "title": "Toggle Floating", "desc": "สลับหน้าต่างลอย / จัดเรียง", "keys": ["SUPER", "T"], "action": "" },
        { "category": "windows", "title": "Pseudo", "desc": "สลับ pseudo tiling", "keys": ["SUPER", "P"], "action": "" },
        { "category": "windows", "title": "Toggle Split", "desc": "สลับ dwindle split", "keys": ["SUPER", "SHIFT", "J"], "action": "" },
        { "category": "windows", "title": "Focus Window", "desc": "โฟกัสแบบ vim (ขวาใช้ semicolon เพราะ L คือล็อก)", "keys": ["SUPER", "H / J / K / ;"], "action": "" },
        { "category": "windows", "title": "Move Window", "desc": "ย้ายหน้าต่างด้วย Super+Shift+ลูกศร", "keys": ["SUPER", "SHIFT", "Arrow Keys"], "action": "" },
        { "category": "windows", "title": "Move Window (Mouse)", "desc": "Super+คลิกซ้ายลากเพื่อย้าย", "keys": ["SUPER", "Left Drag"], "action": "" },
        { "category": "windows", "title": "Resize Window (Mouse)", "desc": "Super+คลิกขวาลากเพื่อย่อขยาย", "keys": ["SUPER", "Right Drag"], "action": "" },

        { "category": "workspaces", "title": "Hotkeys Cheat Sheet", "desc": "เปิด/ปิดหน้าต่างคีย์ลัด", "keys": ["SUPER", "/"], "action": "" },
        { "category": "workspaces", "title": "Focus Workspace 1-10", "desc": "สลับ Workspace 1 ถึง 10", "keys": ["SUPER", "1 .. 9, 0"], "action": "" },
        { "category": "workspaces", "title": "Move Window to Workspace", "desc": "ย้ายหน้าต่างตามไปยัง Workspace", "keys": ["SUPER", "SHIFT", "1 .. 9, 0"], "action": "" },
        { "category": "workspaces", "title": "Cycle Workspaces", "desc": "เวิร์กสเปซก่อนหน้า / ถัดไป (ลูกศรหรือ , / .)", "keys": ["SUPER", "Arrows or , / ."], "action": "" },

        { "category": "tools", "title": "Region Screenshot", "desc": "ลากพื้นที่แล้วคัดลอกไปคลิปบอร์ด", "keys": ["Print"], "action": "" },
        { "category": "tools", "title": "Fullscreen Screenshot", "desc": "แคปทั้งจอลงคลิปบอร์ด", "keys": ["SUPER", "Print"], "action": "" },
        { "category": "tools", "title": "Smart Screenshot", "desc": "คลิกซ้าย = Copy, คลิกขวา = Swappy", "keys": ["SUPER", "SHIFT", "S"], "action": "" },
        { "category": "tools", "title": "OCR Snip", "desc": "แคปข้อความไทย/อังกฤษลงคลิปบอร์ด", "keys": ["SUPER", "SHIFT", "X"], "action": "ocr-snip" },
        { "category": "tools", "title": "Clipboard History", "desc": "ประวัติคลิปบอร์ดผ่าน Fuzzel", "keys": ["SUPER", "V"], "action": "" },
        { "category": "tools", "title": "Color Picker", "desc": "ดูดสี #HEX", "keys": ["SUPER", "SHIFT", "C"], "action": "hyprpicker -a" },
        { "category": "tools", "title": "Pick Wallpaper", "desc": "เลือกวอลเปเปอร์จากรายการ (มี Random)", "keys": ["SUPER", "SHIFT", "W"], "action": "" },

        { "category": "system", "title": "Notification Center", "desc": "เปิด/ปิดแผงแจ้งเตือน SwayNC", "keys": ["SUPER", "N"], "action": "" },
        { "category": "system", "title": "Lock Screen", "desc": "ล็อกหน้าจอ (hyprlock)", "keys": ["SUPER", "L"], "action": "" },
        { "category": "system", "title": "Logout Menu", "desc": "เปิด wlogout", "keys": ["SUPER", "M"], "action": "wlogout" },
        { "category": "system", "title": "Pick Theme", "desc": "เลือกชุดสีทั้งระบบจากเมนู", "keys": ["SUPER", "SHIFT", "T"], "action": "theme-switcher pick" },
        { "category": "system", "title": "Audio Switch", "desc": "สลับอุปกรณ์เสียง", "keys": ["SUPER", "F10"], "action": "audio-switch" },
        { "category": "system", "title": "Battery Saver", "desc": "สลับ battery saver", "keys": ["CTRL", "SUPER", "B"], "action": "" },
        { "category": "system", "title": "Reload Hyprland & Bar", "desc": "รีโหลด Hyprland และ Waybar", "keys": ["CTRL", "SUPER", "R"], "action": "" },
        { "category": "system", "title": "Volume / Mute", "desc": "ปุ่มฮาร์ดแวร์ปรับเสียง", "keys": ["Volume Up / Dn / Mute"], "action": "" },
        { "category": "system", "title": "Brightness", "desc": "ปุ่มฮาร์ดแวร์ปรับความสว่าง", "keys": ["Brightness Up / Dn"], "action": "" }
    ]

    property string selectedCategory: "all"
    property string searchQuery: ""

    // Filtered model calculation
    function getFilteredHotkeys() {
        var query = root.searchQuery.toLowerCase().trim();
        var cat = root.selectedCategory;

        return root.allHotkeys.filter(function(item) {
            // Check category match
            if (cat !== "all" && item.category !== cat) {
                return false;
            }

            // Check query match
            if (query.length === 0) {
                return true;
            }

            var titleMatch = item.title.toLowerCase().indexOf(query) !== -1;
            var descMatch = item.desc.toLowerCase().indexOf(query) !== -1;
            var keysMatch = item.keys.some(function(k) {
                return k.toLowerCase().indexOf(query) !== -1;
            });

            return titleMatch || descMatch || keysMatch;
        });
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            // Scrim / Backdrop Overlay (Click to Dismiss)
            Rectangle {
                anchors.fill: parent
                color: theme.scrimColor

                MouseArea {
                    anchors.fill: parent
                    onClicked: Qt.quit()
                }
            }

            // Central Cheat Sheet Dialog Card
            Rectangle {
                id: dialogCard
                anchors.centerIn: parent
                width: Math.min(parent.width * 0.90, 1080)
                height: Math.min(parent.height * 0.88, 760)
                radius: 16
                color: theme.bgSurface
                border.width: 1.5
                border.color: theme.borderActive

                // Prevent backdrop clicks from closing inside dialog
                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 14

                    // 1. Header Bar
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        // Icon and Title
                        RowLayout {
                            spacing: 10

                            Text {
                                text: "⌨️"
                                font.pixelSize: 24
                            }

                            ColumnLayout {
                                spacing: 2

                                RowLayout {
                                    spacing: 8

                                    Text {
                                        text: "Hyprland Shortcuts & Cheat Sheet"
                                        font.family: "Sans-Serif, Inter, sans-serif"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: theme.fgPrimary
                                    }

                                    KeyBadge {
                                        keyText: "SUPER + /"
                                        theme: theme
                                    }
                                }

                                Text {
                                    text: "Quick reference cheat sheet for system hotkeys & shortcuts"
                                    font.family: "Sans-Serif, Inter, sans-serif"
                                    font.pixelSize: 11
                                    color: theme.fgMuted
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Close Button (×)
                        Rectangle {
                            implicitWidth: 32
                            implicitHeight: 32
                            radius: 16
                            color: closeMouse.containsMouse ? (theme.isLight ? "#D8CBC0" : "#4A3C32") : "transparent"
                            border.width: 1
                            border.color: closeMouse.containsMouse ? theme.borderActive : "transparent"

                            Behavior on color { ColorAnimation { duration: 120 } }

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                font.pixelSize: 14
                                font.bold: true
                                color: closeMouse.containsMouse ? theme.statusRed : theme.fgMuted
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Qt.quit()
                            }
                        }
                    }

                    // 2. Search Box
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 42
                        radius: 10
                        color: theme.bgInput
                        border.width: 1
                        border.color: searchInput.activeFocus ? theme.borderActive : theme.borderSubtle

                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Text {
                                text: "🔍"
                                font.pixelSize: 14
                                opacity: 0.7
                            }

                            TextInput {
                                id: searchInput
                                Layout.fillWidth: true
                                focus: true
                                text: root.searchQuery
                                font.family: "Sans-Serif, Inter, sans-serif"
                                font.pixelSize: 13
                                color: theme.fgPrimary
                                selectByMouse: true

                                onTextChanged: {
                                    root.searchQuery = text;
                                }

                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Escape) {
                                        if (text.length > 0) {
                                            text = "";
                                            event.accepted = true;
                                        } else {
                                            Qt.quit();
                                        }
                                    }
                                }

                                Text {
                                    anchors.fill: parent
                                    visible: !searchInput.text && !searchInput.inputMethodComposing
                                    text: "Search shortcuts by name, action, or key (e.g. terminal, screenshot, workspace, ocr, audio)..."
                                    font.family: "Sans-Serif, Inter, sans-serif"
                                    font.pixelSize: 13
                                    color: theme.fgMuted
                                    opacity: 0.7
                                }
                            }

                            // Clear Search (×) Button
                            Rectangle {
                                visible: searchInput.text.length > 0
                                implicitWidth: 20
                                implicitHeight: 20
                                radius: 10
                                color: clearMouse.containsMouse ? (theme.isLight ? "#C8B9AC" : "#4A3C32") : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    font.pixelSize: 10
                                    color: theme.fgPrimary
                                }

                                MouseArea {
                                    id: clearMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        searchInput.text = "";
                                        searchInput.forceActiveFocus();
                                    }
                                }
                            }
                        }
                    }

                    // 3. Category Filter Chips
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: [
                                { "id": "all", "label": "All (ทั้งหมด)" },
                                { "id": "apps", "label": "🚀 Apps" },
                                { "id": "windows", "label": "🪟 Windows" },
                                { "id": "workspaces", "label": "🎯 Workspaces" },
                                { "id": "tools", "label": "📸 Screenshots & Tools" },
                                { "id": "system", "label": "🔊 Media & System" }
                            ]

                            Rectangle {
                                id: chip
                                property bool isSelected: root.selectedCategory === modelData.id
                                implicitWidth: chipLabel.implicitWidth + 20
                                implicitHeight: 30
                                radius: 15
                                color: isSelected ? theme.accentPurple : (chipMouse.containsMouse ? theme.bgHover : theme.bgCard)
                                border.width: 1
                                border.color: isSelected ? theme.accentPurpleLight : theme.borderSubtle

                                Behavior on color { ColorAnimation { duration: 120 } }
                                Behavior on border.color { ColorAnimation { duration: 120 } }

                                Text {
                                    id: chipLabel
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.family: "Sans-Serif, Inter, sans-serif"
                                    font.pixelSize: 11
                                    font.bold: chip.isSelected
                                    color: chip.isSelected ? (theme.isLight ? "#FFFFFF" : "#E9F3FB") : theme.fgPrimary
                                }

                                MouseArea {
                                    id: chipMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.selectedCategory = modelData.id;
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    // 4. Hotkeys List Area
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ListView {
                            id: listView
                            anchors.fill: parent
                            clip: true
                            spacing: 6
                            model: root.getFilteredHotkeys()

                            delegate: HotkeyCard {
                                width: listView.width - (scrollBar.visible ? 12 : 0)
                                itemData: modelData
                                theme: theme
                            }

                            ScrollBar.vertical: ScrollBar {
                                id: scrollBar
                                policy: listView.contentHeight > listView.height ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
                                contentItem: Rectangle {
                                    implicitWidth: 6
                                    radius: 3
                                    color: theme.accentPurple
                                    opacity: 0.6
                                }
                            }
                        }

                        // Empty Search State
                        ColumnLayout {
                            anchors.centerIn: parent
                            visible: listView.count === 0
                            spacing: 12

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "🔍"
                                font.pixelSize: 36
                                opacity: 0.6
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "No shortcuts found matching '" + root.searchQuery + "'"
                                font.family: "Sans-Serif, Inter, sans-serif"
                                font.pixelSize: 14
                                font.bold: true
                                color: theme.fgPrimary
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Press ESC or click the button below to clear your search"
                                font.family: "Sans-Serif"
                                font.pixelSize: 12
                                color: theme.fgMuted
                            }

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                implicitWidth: clearBtnText.implicitWidth + 24
                                implicitHeight: 32
                                radius: 8
                                color: theme.accentPurple
                                border.width: 1
                                border.color: theme.accentPurpleLight

                                Text {
                                    id: clearBtnText
                                    anchors.centerIn: parent
                                    text: "Clear Search"
                                    font.family: "Sans-Serif"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#FFFFFF"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.searchQuery = "";
                                        searchInput.text = "";
                                        searchInput.forceActiveFocus();
                                    }
                                }
                            }
                        }
                    }

                    // 5. Footer Bar
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 32
                        radius: 8
                        color: theme.bgInput

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12

                            RowLayout {
                                spacing: 8

                                KeyBadge {
                                    keyText: "ESC"
                                    theme: theme
                                    implicitHeight: 20
                                }

                                Text {
                                    text: "to close"
                                    font.family: "Sans-Serif"
                                    font.pixelSize: 11
                                    color: theme.fgMuted
                                }

                                Text {
                                    text: "•"
                                    color: theme.borderSubtle
                                }

                                KeyBadge {
                                    keyText: "Super + /"
                                    theme: theme
                                    implicitHeight: 20
                                }

                                Text {
                                    text: "to toggle"
                                    font.family: "Sans-Serif"
                                    font.pixelSize: 11
                                    color: theme.fgMuted
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "Showing " + listView.count + " of " + root.allHotkeys.length + " shortcuts"
                                font.family: "Sans-Serif"
                                font.pixelSize: 11
                                color: theme.fgMuted
                            }
                        }
                    }
                }
            }
        }
    }
}
