import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../config"
import "../../components"

PanelWindow {
    id: root

    required property var shellRoot

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nhattVim:wallpaper-picker"
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    color: "transparent"
    visible: shellRoot.wallpaperPickerActive

    property string searchText: ""
    property var results: filterWallpapers(searchText)
    property int selectedIndex: 0

    onVisibleChanged: {
        if (visible) {
            WallpaperService.refresh();
            searchText = "";
            searchInput.text = "";
            selectedIndex = Math.max(0, WallpaperService.currentIndex);
            searchInput.forceActiveFocus();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: ThemeService.scrimColor

        MouseArea {
            anchors.fill: parent
            onClicked: shellRoot.wallpaperPickerActive = false
        }
    }

    StyledRect {
        id: pickerCard
        width: 880
        height: 600
        anchors.centerIn: parent
        clip: true
        rectColor: ThemeService.background
        rectOpacity: ThemeService.bgOpacityHigh
        borderOpacityValue: ThemeService.borderOpacity

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Row {
                width: parent.width
                height: 38
                spacing: 12

                Rectangle {
                    width: 38
                    height: 38
                    radius: 14
                    color: Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.16)

                    Text {
                        anchors.centerIn: parent
                        text: "󰸉"
                        color: ThemeService.primary
                        font.family: ThemeService.iconFont
                        font.pixelSize: 19
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 190
                    spacing: 2

                    Text {
                        text: "Wallpaper Picker"
                        color: ThemeService.textBright
                        font.family: ThemeService.fontName
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: root.results.length + " wallpaper" + (root.results.length === 1 ? "" : "s") + " available"
                        color: ThemeService.textDim
                        font.family: ThemeService.fontName
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 128
                    height: 30
                    radius: 11
                    color: ThemeService.surface

                    Text {
                        anchors.centerIn: parent
                        text: "Enter apply · Esc close"
                        color: ThemeService.textDim
                        font.family: ThemeService.fontName
                        font.pixelSize: 10
                    }
                }
            }

            Rectangle {
                id: searchBox
                width: parent.width
                height: 46
                radius: 16
                color: ThemeService.surface
                border.width: 1
                border.color: searchInput.activeFocus
                    ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.72)
                    : Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, 0.14)

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    spacing: 11

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰍉"
                        color: searchInput.activeFocus ? ThemeService.primary : ThemeService.textDim
                        font.family: ThemeService.iconFont
                        font.pixelSize: 17
                    }

                    TextInput {
                        id: searchInput
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 32
                        color: ThemeService.foreground
                        selectionColor: Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.35)
                        selectedTextColor: ThemeService.textBright
                        font.family: ThemeService.fontName
                        font.pixelSize: 13
                        selectByMouse: true
                        clip: true

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            text: "Search wallpapers..."
                            color: ThemeService.textDim
                            font.family: ThemeService.fontName
                            font.pixelSize: 13
                            visible: parent.text.length === 0
                            elide: Text.ElideRight
                        }

                        onTextChanged: {
                            root.searchText = text;
                            root.selectedIndex = 0;
                        }

                        Keys.onPressed: event => {
                            const count = wallpaperGrid.count;
                            const columns = Math.max(1, Math.floor(wallpaperGrid.width / wallpaperGrid.cellWidth));

                            if (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier)) {
                                root.selectNext();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                                root.selectPrevious();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Right) {
                                root.selectNext();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Left) {
                                root.selectPrevious();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down) {
                                if (count > 0) root.selectedIndex = Math.min(count - 1, root.selectedIndex + columns);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Up) {
                                if (count > 0) root.selectedIndex = Math.max(0, root.selectedIndex - columns);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                root.applySelected();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Escape) {
                                shellRoot.wallpaperPickerActive = false;
                                event.accepted = true;
                            }
                        }
                    }
                }
            }

            GridView {
                id: wallpaperGrid
                width: parent.width
                height: parent.height - 130
                clip: true
                model: root.results
                currentIndex: root.selectedIndex
                boundsBehavior: Flickable.StopAtBounds
                cellWidth: width / 4
                cellHeight: 138

                delegate: Item {
                    required property int index
                    required property string modelData

                    width: wallpaperGrid.cellWidth
                    height: wallpaperGrid.cellHeight

                    Rectangle {
                        id: tile
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: 18
                        color: ThemeService.surface
                        clip: true
                        scale: index === root.selectedIndex ? 1.0 : 0.985

                        border.width: index === root.selectedIndex ? 2 : 1
                        border.color: index === root.selectedIndex
                            ? ThemeService.primary
                            : modelData === WallpaperService.currentWallpaper
                                ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.56)
                                : Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, 0.12)

                        Image {
                            anchors.fill: parent
                            source: "file://" + modelData
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: 320
                            sourceSize.height: 200
                            asynchronous: true
                            cache: true
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: itemMouse.containsMouse || index === root.selectedIndex
                                ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.14)
                                : "transparent"
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 42
                            color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, 0.74)

                            Column {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 2

                                Text {
                                    width: parent.width
                                    text: root.fileName(modelData)
                                    color: ThemeService.textBright
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: parent.width
                                    text: modelData === WallpaperService.currentWallpaper ? "Current wallpaper" : "Click to apply"
                                    color: modelData === WallpaperService.currentWallpaper ? ThemeService.primary : ThemeService.textDim
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 9
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 9
                            width: 28
                            height: 24
                            radius: 9
                            visible: modelData === WallpaperService.currentWallpaper
                            color: ThemeService.primary

                            Text {
                                anchors.centerIn: parent
                                text: "󰄬"
                                color: ThemeService.background
                                font.family: ThemeService.iconFont
                                font.pixelSize: 13
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.margins: 9
                            width: 30
                            height: 24
                            radius: 9
                            visible: index === root.selectedIndex
                            color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, 0.72)
                            border.width: 1
                            border.color: ThemeService.primary

                            Text {
                                anchors.centerIn: parent
                                text: index + 1
                                color: ThemeService.primary
                                font.family: ThemeService.fontName
                                font.pixelSize: 11
                                font.weight: Font.Bold
                            }
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.selectedIndex = index
                            onClicked: {
                                WallpaperService.setWallpaperByPath(modelData);
                                shellRoot.wallpaperPickerActive = false;
                            }
                        }
                    }
                }

                onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)
            }

            Row {
                width: parent.width
                height: 18
                spacing: 14

                Text {
                    text: "←↑↓→ navigate"
                    color: ThemeService.textDim
                    font.family: ThemeService.fontName
                    font.pixelSize: 10
                }

                Text {
                    text: "Enter apply"
                    color: ThemeService.textDim
                    font.family: ThemeService.fontName
                    font.pixelSize: 10
                }

                Text {
                    text: "Directory: " + WallpaperService.wallpaperDir
                    color: ThemeService.textDim
                    font.family: ThemeService.fontName
                    font.pixelSize: 10
                    width: parent.width - 210
                    elide: Text.ElideRight
                }
            }
        }

        Item {
            anchors.fill: parent
            visible: !WallpaperService.wallpaperPaths.length

            Column {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰋩"
                    color: ThemeService.textDim
                    font.family: ThemeService.iconFont
                    font.pixelSize: 38
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No wallpapers found"
                    color: ThemeService.textDim
                    font.family: ThemeService.fontName
                    font.pixelSize: 13
                }
            }
        }
    }

    function filterWallpapers(query) {
        const needle = (query || "").toLowerCase();
        if (needle === "") return WallpaperService.wallpaperPaths;
        return WallpaperService.wallpaperPaths.filter(path => fileName(path).toLowerCase().indexOf(needle) !== -1 || path.toLowerCase().indexOf(needle) !== -1);
    }

    function fileName(path) {
        const parts = String(path).split("/");
        return parts.length > 0 ? parts[parts.length - 1] : String(path);
    }

    function applySelected() {
        if (selectedIndex >= 0 && selectedIndex < results.length) {
            WallpaperService.setWallpaperByPath(results[selectedIndex]);
            shellRoot.wallpaperPickerActive = false;
        }
    }

    function selectNext() {
        if (results.length <= 0) return;
        selectedIndex = (selectedIndex + 1) % results.length;
    }

    function selectPrevious() {
        if (results.length <= 0) return;
        selectedIndex = (selectedIndex - 1 + results.length) % results.length;
    }
}
