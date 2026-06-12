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

    Rectangle {
        anchors.fill: parent
        color: ThemeService.scrimColor

        MouseArea {
            anchors.fill: parent
            onClicked: shellRoot.clipboardActive = false
        }
    }

    StyledRect {
        id: clipboardCard
        width: 520
        height: 400
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
            anchors.margins: 14
            spacing: 10

            Rectangle {
                id: searchBox
                width: parent.width
                height: 40
                radius: 14
                color: ThemeService.surface
                border.width: 1
                border.color: searchInput.activeFocus
                    ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.75)
                    : Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, 0.16)

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
                        font.pixelSize: 16
                    }

                    TextInput {
                        id: searchInput
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 28
                        color: ThemeService.foreground
                        selectionColor: Qt.rgba(
                            ThemeService.primary.r,
                            ThemeService.primary.g,
                            ThemeService.primary.b,
                            0.35
                        )
                        selectedTextColor: ThemeService.textBright
                        font.family: ThemeService.fontName
                        font.pixelSize: 13
                        selectByMouse: true
                        clip: true

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Search clipboard history"
                            color: ThemeService.textDim
                            font.family: ThemeService.fontName
                            font.pixelSize: 13
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

            ListView {
                id: clipboardList
                width: parent.width
                height: parent.height - 76
                clip: true
                spacing: 6
                model: root.results
                currentIndex: root.selectedIndex
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    required property int index
                    required property var modelData

                    width: clipboardList.width
                    height: 46
                    radius: 13
                    color: index === root.selectedIndex
                        ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.15)
                        : itemMouse.containsMouse
                            ? Qt.rgba(ThemeService.surfaceBright.r, ThemeService.surfaceBright.g, ThemeService.surfaceBright.b, 0.52)
                            : ThemeService.surface

                    border.width: 1
                    border.color: index === root.selectedIndex
                        ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.7)
                        : Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, 0.1)

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.selectedIndex = index
                        onClicked: {
                            ClipboardService.copyEntry(modelData.line);
                            shellRoot.clipboardActive = false;
                        }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 28
                            height: 28
                            radius: 10
                            color: index === root.selectedIndex
                                ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.2)
                                : Qt.rgba(ThemeService.surfaceBright.r, ThemeService.surfaceBright.g, ThemeService.surfaceBright.b, 0.55)

                            Text {
                                anchors.centerIn: parent
                                text: index + 1
                                color: index === root.selectedIndex ? ThemeService.primary : ThemeService.textDim
                                font.family: ThemeService.fontName
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 68
                            text: modelData.preview
                            color: index === root.selectedIndex ? ThemeService.textBright : ThemeService.foreground
                            font.family: ThemeService.fontName
                            font.pixelSize: 13
                            elide: Text.ElideRight
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "󰆏"
                            color: index === root.selectedIndex ? ThemeService.primary : ThemeService.textDim
                            font.family: ThemeService.iconFont
                            font.pixelSize: 15
                            opacity: index === root.selectedIndex || itemMouse.containsMouse ? 1 : 0
                        }
                    }
                }

                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
            }

            Row {
                width: parent.width
                height: 16
                spacing: 10

                Text {
                    text: root.results.length + " item" + (root.results.length === 1 ? "" : "s")
                    color: ThemeService.textDim
                    font.family: ThemeService.fontName
                    font.pixelSize: 10
                }

                Text {
                    text: "Enter copy"
                    color: ThemeService.textDim
                    font.family: ThemeService.fontName
                    font.pixelSize: 10
                }

                Text {
                    text: "Delete remove"
                    color: ThemeService.textDim
                    font.family: ThemeService.fontName
                    font.pixelSize: 10
                }

                Text {
                    text: "Shift+Delete clear all"
                    color: ThemeService.textDim
                    font.family: ThemeService.fontName
                    font.pixelSize: 10
                }
            }
        }

        Item {
            anchors.fill: parent
            visible: !ClipboardService.loading && root.results.length === 0

            Column {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: ClipboardService.error !== "" ? "󰅚" : "󰅇"
                    color: ClipboardService.error !== "" ? ThemeService.danger : ThemeService.textDim
                    font.family: ThemeService.iconFont
                    font.pixelSize: 34
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: ClipboardService.error !== "" ? ClipboardService.error : "Clipboard history is empty"
                    color: ThemeService.textDim
                    font.family: ThemeService.fontName
                    font.pixelSize: 13
                }
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
            selectedIndex = Math.max(0, Math.min(selectedIndex, results.length - 2));
        }
    }
}
