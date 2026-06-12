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
    WlrLayershell.namespace: "nhattVim:clipboard"
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    color: "transparent"
    visible: shellRoot.clipboardActive

    property string searchText: ""
    property var results: ClipboardService.search(searchText)
    property int selectedIndex: 0

    onVisibleChanged: {
        if (visible) {
            searchText = "";
            searchInput.text = "";
            selectedIndex = 0;
            ClipboardService.refresh();
            searchInput.forceActiveFocus();
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: shellRoot.clipboardActive = false
    }

    StyledRect {
        id: clipboardCard
        width: 520
        height: 430
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
            anchors.margins: ThemeService.spacingLarge
            spacing: ThemeService.spacingMedium

            Row {
                width: parent.width
                height: 40
                spacing: 8

                Rectangle {
                    width: parent.width
                    height: parent.height
                    radius: ThemeService.radiusSmall
                    color: ThemeService.surfaceBright
                    border.color: ThemeService.primary
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: ThemeService.radiusMedium
                        anchors.rightMargin: ThemeService.radiusMedium
                        spacing: 10

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "󰅇"
                            color: ThemeService.primary
                            font.family: ThemeService.iconFont
                            font.pixelSize: 16
                        }

                        TextInput {
                            id: searchInput
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 28
                            color: ThemeService.foreground
                            font.family: ThemeService.fontName
                            font.pixelSize: 13
                            selectByMouse: true

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Search clipboard...  Enter copy  Delete remove  Shift+Delete clear all"
                                color: ThemeService.textDim
                                font.family: ThemeService.fontName
                                font.pixelSize: 12
                                visible: parent.text.length === 0
                                width: parent.width
                                elide: Text.ElideRight
                            }

                            onTextChanged: {
                                root.searchText = text;
                                root.selectedIndex = 0;
                            }

                            Keys.onPressed: event => {
                                const count = clipboardList.count;
                                if (event.key === Qt.Key_Down || (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) {
                                    if (count > 0) root.selectedIndex = (root.selectedIndex + 1) % count;
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_Backtab) || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                                    if (count > 0) root.selectedIndex = (root.selectedIndex - 1 + count) % count;
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                    root.copySelected();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Delete) {
                                    if (event.modifiers & Qt.ShiftModifier) {
                                        ClipboardService.clearAll();
                                    } else {
                                        root.deleteSelected();
                                    }
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Escape) {
                                    shellRoot.clipboardActive = false;
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                }

            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, 0.12)
            }

            ListView {
                id: clipboardList
                width: parent.width
                height: parent.height - 52
                clip: true
                spacing: 7
                model: root.results
                currentIndex: root.selectedIndex

                delegate: Rectangle {
                    required property int index
                    required property var modelData

                    width: clipboardList.width
                    height: 54
                    radius: ThemeService.radiusSmall
                    color: index === root.selectedIndex
                        ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.16)
                        : (itemMouse.containsMouse ? Qt.rgba(ThemeService.surfaceBright.r, ThemeService.surfaceBright.g, ThemeService.surfaceBright.b, 0.42) : ThemeService.surface)
                    border.width: 1
                    border.color: index === root.selectedIndex ? ThemeService.primary : ThemeService.surfaceBright

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton
                        onEntered: root.selectedIndex = index
                        onClicked: {
                            ClipboardService.copyEntry(modelData.line);
                            shellRoot.clipboardActive = false;
                        }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 8
                        spacing: 10

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 34
                            text: "#" + (index + 1)
                            color: ThemeService.textDim
                            font.family: ThemeService.fontName
                            font.pixelSize: 10
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 46
                            text: modelData.preview
                            color: index === root.selectedIndex ? ThemeService.textBright : ThemeService.foreground
                            font.family: ThemeService.fontName
                            font.pixelSize: 13
                            elide: Text.ElideRight
                        }

                    }
                }

                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 190
                visible: !ClipboardService.loading && root.results.length === 0
                text: ClipboardService.error !== "" ? ClipboardService.error : "Clipboard history is empty"
                color: ThemeService.textDim
                font.family: ThemeService.fontName
                font.pixelSize: 12
            }
        }
    }

    function copySelected() {
        if (selectedIndex >= 0 && selectedIndex < results.length) {
            ClipboardService.copyEntry(results[selectedIndex].line);
            shellRoot.clipboardActive = false;
        }
    }

    function deleteSelected() {
        if (selectedIndex >= 0 && selectedIndex < results.length) {
            ClipboardService.deleteEntry(results[selectedIndex].line);
        }
    }
}
