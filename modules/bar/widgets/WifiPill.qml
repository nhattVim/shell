import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../../services"
import "../../../config"
import "../../../components"

StyledRect {
    id: root

    property int pillHeight: ThemeService.sideCapsuleHeight
    property int closePopupsToken: 0

    signal popupOpened()

    height: pillHeight
    width: wifiRow.implicitWidth + ThemeService.radiusLarge
    radius: height / 2
    rectColor: ThemeService.background
    rectOpacity: ThemeService.bgOpacity
    borderOpacityValue: 0.0

    Row {
        id: wifiRow
        anchors.centerIn: parent
        spacing: ThemeService.spacingSmall

        Text {
            text: NetworkService.wifiIcon
            font.family: ThemeService.iconFont
            font.pixelSize: 13
            color: NetworkService.wifiConnected ? ThemeService.secondary : ThemeService.textDim
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: NetworkService.wifiConnected ? NetworkService.wifiSignal + "%" : "Off"
            font.family: ThemeService.fontName
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: NetworkService.wifiConnected ? ThemeService.foreground : ThemeService.textDim
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: wifiPopup.toggle()
        onEntered: root.rectOpacity = 1.0
        onExited: root.rectOpacity = ThemeService.bgOpacity
    }

    PopupWindow {
        id: wifiPopup

        property int popupWidth: 280
        property int popupMaxHeight: 360
        property int popupPadding: 10
        property real popupOpacity: 0
        property real popupScale: 0.94

        anchor.item: root
        anchor.rect.x: root.width - implicitWidth
        anchor.rect.y: root.height + ThemeService.spacingMedium
        anchor.rect.width: 0
        anchor.rect.height: 0

        implicitWidth: popupWidth
        implicitHeight: Math.min(wifiColumn.implicitHeight + popupPadding * 2, popupMaxHeight)
        color: "transparent"
        grabFocus: true
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: ThemeService.radiusMedium
            color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, ThemeService.bgOpacityHigh)
            border.width: 1
            border.color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, ThemeService.borderOpacity)
            opacity: wifiPopup.popupOpacity
            scale: wifiPopup.popupScale
            transformOrigin: Item.TopRight

            Behavior on opacity { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutCubic } }

            Flickable {
                anchors.fill: parent
                anchors.margins: wifiPopup.popupPadding
                contentWidth: width
                contentHeight: wifiColumn.implicitHeight
                clip: true

                Column {
                    id: wifiColumn
                    width: parent.width
                    spacing: 6

                    Row {
                        width: parent.width
                        height: 30
                        spacing: ThemeService.spacingSmall

                        Text {
                            text: "󰤨"
                            font.family: ThemeService.iconFont
                            font.pixelSize: 15
                            color: ThemeService.secondary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            width: parent.width - wifiToggle.width - 30
                            text: "Wi-Fi"
                            color: ThemeService.textBright
                            font.family: ThemeService.fontName
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledRect {
                            id: wifiToggle
                            width: 34
                            height: 18
                            radius: height / 2
                            rectColor: NetworkService.wifiEnabled ? ThemeService.primary : ThemeService.surfaceBright
                            rectOpacity: NetworkService.wifiEnabled ? 0.95 : (toggleMouse.containsMouse ? 0.6 : 0.35)
                            borderOpacityValue: 0.0

                            Rectangle {
                                width: 14
                                height: 14
                                radius: 7
                                x: NetworkService.wifiEnabled ? parent.width - width - 2 : 2
                                anchors.verticalCenter: parent.verticalCenter
                                color: NetworkService.wifiEnabled ? ThemeService.background : ThemeService.textDim
                                Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }
                                Behavior on color { ColorAnimation { duration: 160 } }
                            }

                            MouseArea {
                                id: toggleMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: NetworkService.setWifiEnabled(!NetworkService.wifiEnabled)
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: ThemeService.surfaceBright; opacity: 0.8 }

                    Text {
                        visible: NetworkService.wifiConnected
                        width: parent.width
                        text: "Connected to " + NetworkService.wifiName
                        color: ThemeService.textDim
                        font.family: ThemeService.fontName
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    Repeater {
                        model: NetworkService.wifiEnabled ? NetworkService.wifiNetworks : []

                        StyledRect {
                            id: wifiItem
                            required property var modelData
                            width: wifiColumn.width
                            height: 36
                            radius: ThemeService.radiusSmall
                            rectColor: modelData.active ? ThemeService.primary : ThemeService.surfaceBright
                            rectOpacity: modelData.active ? 0.22 : (wifiItemMouse.containsMouse ? 0.55 : 0.2)
                            borderOpacityValue: 0.0

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 9
                                anchors.rightMargin: 9
                                spacing: ThemeService.spacingSmall

                                Text {
                                    text: modelData.signal >= 75 ? "󰤨" : (modelData.signal >= 50 ? "󰤥" : (modelData.signal >= 25 ? "󰤢" : "󰤟"))
                                    font.family: ThemeService.iconFont
                                    font.pixelSize: 13
                                    color: modelData.active ? ThemeService.primary : ThemeService.foreground
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    width: parent.width - 72
                                    text: modelData.ssid
                                    color: modelData.active ? ThemeService.textBright : ThemeService.foreground
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 12
                                    font.weight: modelData.active ? Font.DemiBold : Font.Medium
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData.secured ? "󰌾" : ""
                                    font.family: ThemeService.iconFont
                                    font.pixelSize: 12
                                    color: ThemeService.textDim
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData.active ? "✓" : modelData.signal + "%"
                                    font.pixelSize: 11
                                    color: modelData.active ? ThemeService.success : ThemeService.textDim
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: wifiItemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    NetworkService.connectToNetwork(modelData);
                                    wifiPopup.close();
                                }
                            }
                        }
                    }

                    Text {
                        visible: !NetworkService.wifiEnabled || NetworkService.wifiNetworks.length === 0
                        width: parent.width
                        text: !NetworkService.wifiEnabled ? "Wi-Fi is off" : (NetworkService.scanning ? "Scanning..." : "No networks found")
                        color: ThemeService.textDim
                        font.family: ThemeService.fontName
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        padding: 10
                    }
                }
            }
        }

        Timer {
            id: closeTimer
            interval: ThemeService.animDuration + 50
            onTriggered: wifiPopup.visible = false
        }

        function open() {
            if (visible) return;
            root.popupOpened();
            NetworkService.refresh();
            if (NetworkService.wifiEnabled) NetworkService.rescan();
            popupOpacity = 0;
            popupScale = 0.94;
            visible = true;
            Qt.callLater(() => {
                popupOpacity = 1;
                popupScale = 1;
            });
        }

        function close() {
            if (!visible) return;
            popupOpacity = 0;
            popupScale = 0.94;
            closeTimer.restart();
        }

        function toggle() {
            if (visible) close();
            else open();
        }
    }

    onClosePopupsTokenChanged: wifiPopup.close()
}
