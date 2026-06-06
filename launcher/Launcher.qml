import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../services"
import "../components"

PanelWindow {
    id: launcherWindow

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // Layer shell settings
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-launcher"

    color: shellRoot.launcherActive ? Qt.rgba(0, 0, 0, 0.4) : "transparent"
    visible: shellRoot.launcherActive

    Behavior on color {
        ColorAnimation { duration: ThemeService.animDuration }
    }

    onVisibleChanged: {
        if (visible) {
            searchText = "";
            searchInputText.text = "";
            searchInputText.forceActiveFocus();
        }
    }

    // Dismiss launcher when clicking outside the main card
    MouseArea {
        anchors.fill: parent
        onClicked: {
            shellRoot.launcherActive = false;
        }
    }

    // Centered glassmorphic launcher card
    StyledRect {
        id: launcherCard
        width: 440
        height: 380
        anchors.centerIn: parent

        // Prevent clicks inside the card from closing it
        MouseArea {
            anchors.fill: parent
            onClicked: {} // Consume click
        }

        // Inner layout
        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            // --- SEARCH BOX ---
            Rectangle {
                width: parent.width
                height: 40
                radius: 8
                color: ThemeService.surfaceBright
                border.color: ThemeService.primary
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text {
                        text: "" // Search icon
                        font.pixelSize: 16
                        color: ThemeService.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextInput {
                        id: searchInputText
                        width: parent.width - 32
                        color: ThemeService.foreground
                        font.family: ThemeService.fontName
                        font.pixelSize: 13
                        focus: true
                        anchors.verticalCenter: parent.verticalCenter
                        selectByMouse: true

                        // Visual placeholder
                        Text {
                            text: "Search applications..."
                            color: ThemeService.textDim
                            font.family: ThemeService.fontName
                            font.pixelSize: 13
                            visible: parent.text.length === 0
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        onTextChanged: {
                            launcherWindow.searchText = text;
                            launcherWindow.selectedIndex = 0;
                        }

                        Keys.onPressed: event => {
                            let resultsList = launcherWindow.results;
                            if (event.key === Qt.Key_Down) {
                                launcherWindow.selectedIndex = (launcherWindow.selectedIndex + 1) % resultsList.length;
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Up) {
                                launcherWindow.selectedIndex = (launcherWindow.selectedIndex - 1 + resultsList.length) % resultsList.length;
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                if (resultsList.length > 0 && launcherWindow.selectedIndex >= 0 && launcherWindow.selectedIndex < resultsList.length) {
                                    LauncherService.launch(resultsList[launcherWindow.selectedIndex]);
                                    shellRoot.launcherActive = false;
                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Escape) {
                                shellRoot.launcherActive = false;
                                event.accepted = true;
                            }
                        }
                    }
                }
            }

            // --- SEPARATOR ---
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, 0.1)
            }

            // --- RESULTS COLUMN ---
            Column {
                width: parent.width
                spacing: 6

                Repeater {
                    model: launcherWindow.results

                    // Item Delegate
                    Rectangle {
                        id: itemRect
                        required property int index
                        required property var modelData // { name, icon, comment, entry }

                        width: parent.width
                        height: 42
                        radius: 8
                        color: (index === launcherWindow.selectedIndex) ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.15) : (itemMouseArea.containsMouse ? Qt.rgba(ThemeService.surfaceBright.r, ThemeService.surfaceBright.g, ThemeService.surfaceBright.b, 0.4) : "transparent")
                        border.color: (index === launcherWindow.selectedIndex) ? ThemeService.primary : "transparent"
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            IconImage {
                                width: 24
                                height: 24
                                anchors.verticalCenter: parent.verticalCenter
                                source: Quickshell.iconPath(modelData.icon) || ""
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 44

                                Text {
                                    text: modelData.name
                                    color: (index === launcherWindow.selectedIndex) ? ThemeService.primary : ThemeService.foreground
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: modelData.comment
                                    color: ThemeService.textDim
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    visible: text !== ""
                                }
                            }
                        }

                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                LauncherService.launch(modelData);
                                shellRoot.launcherActive = false;
                            }
                        }
                    }
                }
            }

            // Optional notice when no results
            Text {
                text: "No applications found"
                color: ThemeService.textDim
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                visible: launcherWindow.results.length === 0
                padding: 20
            }
        }
    }

    // Properties tracking search state
    property string searchText: ""
    property var results: LauncherService.search(searchText)
    property int selectedIndex: 0
}
