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

    color: shellRoot.launcherActive ? ThemeService.scrimColor : "transparent"
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
        width: ThemeService.launcherWidth
        height: ThemeService.launcherHeight
        anchors.centerIn: parent
        clip: true // Ensure content stays inside

        // Prevent clicks inside the card from closing it
        MouseArea {
            anchors.fill: parent
            onClicked: {} // Consume click
        }

        // Inner layout
        Column {
            anchors.fill: parent
            anchors.margins: ThemeService.spacingLarge
            spacing: ThemeService.spacingLarge

            // --- SEARCH BOX ---
            Rectangle {
                width: parent.width
                height: ThemeService.launcherSearchHeight
                radius: ThemeService.radiusSmall
                color: ThemeService.surfaceBright
                border.color: ThemeService.primary
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: ThemeService.radiusMedium
                    anchors.rightMargin: ThemeService.radiusMedium
                    spacing: ThemeService.spacingMedium

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
                            let resultsCount = resultsListView.count;
                            if (event.key === Qt.Key_Down || (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) {
                                if (resultsCount > 0) {
                                    launcherWindow.selectedIndex = (launcherWindow.selectedIndex + 1) % resultsCount;
                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_Backtab) || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                                if (resultsCount > 0) {
                                    launcherWindow.selectedIndex = (launcherWindow.selectedIndex - 1 + resultsCount) % resultsCount;
                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                if (resultsCount > 0 && launcherWindow.selectedIndex >= 0 && launcherWindow.selectedIndex < resultsCount) {
                                    LauncherService.launch(launcherWindow.results[launcherWindow.selectedIndex]);
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

            // --- RESULTS LIST ---
            ListView {
                id: resultsListView
                width: parent.width
                height: ThemeService.launcherListHeight // Exactly 6 items
                model: launcherWindow.results
                clip: true
                spacing: ThemeService.spacingSmall
                
                currentIndex: launcherWindow.selectedIndex
                highlightFollowsCurrentItem: true
                
                delegate: Rectangle {
                    id: itemRect
                    required property int index
                    required property var modelData // { name, icon, comment, entry }

                    width: resultsListView.width
                    height: ThemeService.launcherItemHeight
                    radius: ThemeService.radiusSmall
                    color: (index === launcherWindow.selectedIndex) ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.15) : (itemMouseArea.containsMouse ? Qt.rgba(ThemeService.surfaceBright.r, ThemeService.surfaceBright.g, ThemeService.surfaceBright.b, 0.4) : "transparent")
                    border.color: (index === launcherWindow.selectedIndex) ? ThemeService.primary : "transparent"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: ThemeService.radiusMedium
                        anchors.rightMargin: ThemeService.radiusMedium
                        spacing: ThemeService.radiusMedium

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
                
                onCurrentIndexChanged: {
                    positionViewAtIndex(currentIndex, ListView.Contain);
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
