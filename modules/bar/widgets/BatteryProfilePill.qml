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
    property var triggerProfile: null
    property var profileActions: [
        { icon: "󰌪", label: "Power Saver", color: ThemeService.secondary, action: "power-saver" },
        { icon: "󰗑", label: "Balanced", color: ThemeService.primary, action: "balanced" },
        { icon: "󰓅", label: "Performance", color: ThemeService.warning, action: "performance" }
    ]

    signal popupOpened()

    height: pillHeight
    width: batteryRow.implicitWidth + ThemeService.radiusLarge
    radius: height / 2
    rectColor: ThemeService.background
    rectOpacity: ThemeService.bgOpacity
    borderOpacityValue: 0.0

    Row {
        id: batteryRow
        anchors.centerIn: parent
        spacing: ThemeService.spacingSmall

        Text {
            text: BatteryService.isCharging ? "󰂄" : ""
            font.family: ThemeService.iconFont
            font.pixelSize: 12
            color: BatteryService.isCharging ? ThemeService.success : ThemeService.secondary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: BatteryService.available ? Math.round(BatteryService.percentage) + "%" : "AC"
            font.family: ThemeService.fontName
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: ThemeService.foreground
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: batteryPopup.toggle()
        onEntered: root.rectOpacity = 1.0
        onExited: root.rectOpacity = ThemeService.bgOpacity
    }

    PopupWindow {
        id: batteryPopup

        property int popupWidth: 306
        property int popupPadding: 10
        property real popupOpacity: 0
        property real popupScale: 0.94

        anchor.item: root
        anchor.rect.x: root.width - implicitWidth
        anchor.rect.y: root.height + ThemeService.spacingMedium
        anchor.rect.width: 0
        anchor.rect.height: 0

        implicitWidth: popupWidth
        implicitHeight: profileRow.implicitHeight + popupPadding * 2
        color: "transparent"
        grabFocus: true
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: ThemeService.radiusMedium
            color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, ThemeService.bgOpacityHigh)
            border.width: 1
            border.color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, ThemeService.borderOpacity)
            opacity: batteryPopup.popupOpacity
            scale: batteryPopup.popupScale
            transformOrigin: Item.TopRight

            Behavior on opacity { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutCubic } }

            Row {
                id: profileRow
                anchors.centerIn: parent
                spacing: ThemeService.spacingSmall

                Repeater {
                    model: root.profileActions

                    StyledRect {
                        id: profileItem
                        required property var modelData
                        readonly property bool active: PowerProfileService.activeProfile === modelData.action
                        width: 90
                        height: 76
                        radius: ThemeService.radiusSmall
                        rectColor: active ? ThemeService.primary : ThemeService.surfaceBright
                        rectOpacity: active ? 0.22 : (profileMouse.containsMouse ? 0.55 : 0.2)
                        borderColor: active ? ThemeService.primary : ThemeService.border
                        borderOpacityValue: active ? 0.55 : (profileMouse.containsMouse ? 0.2 : 0.0)

                        Column {
                            anchors.centerIn: parent
                            spacing: ThemeService.spacingSmall

                            Text {
                                text: modelData.icon
                                font.family: ThemeService.iconFont
                                font.pixelSize: 23
                                color: modelData.color
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                width: profileItem.width - 12
                                text: modelData.label
                                color: profileItem.active ? ThemeService.textBright : ThemeService.foreground
                                font.family: ThemeService.fontName
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: profileMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.triggerProfile) root.triggerProfile(modelData.action);
                                batteryPopup.close();
                            }
                        }
                    }
                }
            }
        }

        Timer {
            id: closeTimer
            interval: ThemeService.animDuration + 50
            onTriggered: batteryPopup.visible = false
        }

        function open() {
            if (visible) return;
            root.popupOpened();
            PowerProfileService.refresh();
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

    onClosePopupsTokenChanged: batteryPopup.close()
}
