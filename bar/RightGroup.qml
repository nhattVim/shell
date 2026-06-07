import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../services"
import "../components"

Row {
    id: root
    spacing: ThemeService.spacingMedium
    
    property int pillHeight: ThemeService.sideCapsuleHeight
    property string islandState: ""
    property bool trayPopupOpen: false
    property int closeTrayPopupsToken: 0
    property var triggerProfile: null
    signal requestIslandState(string state)

    function closeTrayPopups() {
        closeTrayPopupsToken++;
        trayPopupOpen = false;
    }

    // Wi-Fi Pill
    StyledRect {
        id: wifiPill
        height: root.pillHeight
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
            onEntered: wifiPill.rectOpacity = 1.0
            onExited: wifiPill.rectOpacity = ThemeService.bgOpacity
        }

        PopupWindow {
            id: wifiPopup
            property int popupWidth: 280
            property int popupMaxHeight: 360
            property int popupPadding: 10
            property real popupOpacity: 0
            property real popupScale: 0.94

            anchor.item: wifiPill
            anchor.rect.x: wifiPill.width - implicitWidth
            anchor.rect.y: wifiPill.height + ThemeService.spacingMedium
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
                id: wifiPopupCloseTimer
                interval: ThemeService.animDuration + 50
                onTriggered: wifiPopup.visible = false
            }

            function open() {
                if (visible) return;
                root.closeTrayPopups();
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
                wifiPopupCloseTimer.restart();
            }

            function toggle() {
                if (visible) close();
                else open();
            }

            Connections {
                target: root
                function onCloseTrayPopupsTokenChanged() {
                    wifiPopup.close();
                }
            }
        }
    }

    // System Tray Pill
    StyledRect {
        id: trayPill
        height: root.pillHeight
        width: trayRow.implicitWidth + ThemeService.islandEarSize
        radius: height / 2
        visible: trayRow.count > 0
        rectColor: ThemeService.background
        rectOpacity: ThemeService.bgOpacity
        borderOpacityValue: 0.0
        
        Row {
            id: trayRow
            anchors.centerIn: parent
            spacing: ThemeService.spacingSmall
            property int count: trayRepeater.count
            Repeater {
                id: trayRepeater
                model: SystemTray.items
                Item {
                    id: trayDelegate
                    required property var modelData
                    width: ThemeService.iconSizeTray
                    height: width

                    IconImage {
                        anchors.fill: parent
                        source: {
                            const icon = trayDelegate.modelData.icon ? trayDelegate.modelData.icon.toString() : "";
                            if (icon.length === 0) return Quickshell.iconPath("image-missing");
                            if (icon.includes("/") || icon.includes(".")) return trayDelegate.modelData.icon;
                            return Quickshell.iconPath(icon, "image-missing");
                        }
                        smooth: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: event => {
                            if (event.button === Qt.LeftButton) {
                                trayDelegate.modelData.activate();
                            } else if (event.button === Qt.RightButton && trayDelegate.modelData.hasMenu) {
                                trayPopup.toggle();
                            }
                            event.accepted = true;
                        }
                    }

                    PopupWindow {
                        id: trayPopup
                        property bool isOpen: false
                        property int popupWidth: 240
                        property int popupMaxHeight: 420
                        property int popupPadding: 8
                        property real popupOpacity: 0
                        property real popupScale: 0.94

                        anchor.item: trayDelegate
                        anchor.rect.x: trayDelegate.width - implicitWidth
                        anchor.rect.y: trayDelegate.height + ThemeService.spacingMedium
                        anchor.rect.width: 0
                        anchor.rect.height: 0

                        implicitWidth: popupWidth
                        implicitHeight: Math.min(menuColumn.implicitHeight + popupPadding * 2, popupMaxHeight)
                        color: "transparent"
                        grabFocus: true
                        visible: false

                        QsMenuOpener {
                            id: menuOpener
                            menu: trayDelegate.modelData.menu
                        }

                        HyprlandFocusGrab {
                            active: trayPopup.visible
                            windows: [trayPopup]
                            onCleared: trayPopup.close()
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: ThemeService.radiusMedium
                            color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, ThemeService.bgOpacityHigh)
                            border.width: 1
                            border.color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, ThemeService.borderOpacity)
                            opacity: trayPopup.popupOpacity
                            scale: trayPopup.popupScale
                            transformOrigin: Item.TopRight

                            Behavior on opacity { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutCubic } }
                            Behavior on scale { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutCubic } }

                            Flickable {
                                anchors.fill: parent
                                anchors.margins: trayPopup.popupPadding
                                contentWidth: width
                                contentHeight: menuColumn.implicitHeight
                                clip: true

                                Column {
                                    id: menuColumn
                                    width: parent.width
                                    spacing: 2

                                    Repeater {
                                        model: menuOpener.children ? menuOpener.children.values : []

                                        Column {
                                            required property var modelData
                                            width: menuColumn.width
                                            spacing: 2
                                            property bool submenuExpanded: false

                                            TrayMenuItem {
                                                width: parent.width
                                                textStr: modelData.text || ""
                                                iconSource: modelData.icon || ""
                                                isSeparator: modelData.isSeparator || false
                                                hasSubmenu: modelData.hasChildren || false
                                                expanded: parent.submenuExpanded
                                                buttonType: modelData.buttonType || 0
                                                checkState: modelData.checkState || 0

                                                onClicked: {
                                                    if (modelData.hasChildren) {
                                                        parent.submenuExpanded = !parent.submenuExpanded;
                                                    } else {
                                                        if (modelData.triggered) modelData.triggered();
                                                        else if (modelData.activate) modelData.activate();
                                                        trayPopup.close();
                                                    }
                                                }
                                            }

                                            Column {
                                                visible: parent.submenuExpanded && modelData.hasChildren
                                                width: parent.width
                                                spacing: 2

                                                QsMenuOpener {
                                                    id: subMenuOpener
                                                    menu: modelData.hasChildren ? modelData : null
                                                }

                                                Repeater {
                                                    model: subMenuOpener.children ? subMenuOpener.children.values : []

                                                    TrayMenuItem {
                                                        required property var modelData
                                                        width: parent.width
                                                        depth: 1
                                                        textStr: modelData.text || ""
                                                        iconSource: modelData.icon || ""
                                                        isSeparator: modelData.isSeparator || false
                                                        buttonType: modelData.buttonType || 0
                                                        checkState: modelData.checkState || 0

                                                        onClicked: {
                                                            if (modelData.triggered) modelData.triggered();
                                                            else if (modelData.activate) modelData.activate();
                                                            trayPopup.close();
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Timer {
                            id: trayPopupCloseTimer
                            interval: ThemeService.animDuration + 50
                            onTriggered: trayPopup.visible = false
                        }

                        function open() {
                            if (visible) return;
                            root.closeTrayPopups();
                            isOpen = true;
                            popupOpacity = 0;
                            popupScale = 0.94;
                            visible = true;
                            root.trayPopupOpen = true;
                            Qt.callLater(() => {
                                popupOpacity = 1;
                                popupScale = 1;
                            });
                        }

                        function close() {
                            if (!visible) return;
                            isOpen = false;
                            popupOpacity = 0;
                            popupScale = 0.94;
                            root.trayPopupOpen = false;
                            trayPopupCloseTimer.restart();
                        }

                        function toggle() {
                            if (visible) close();
                            else open();
                        }

                        Connections {
                            target: root
                            function onCloseTrayPopupsTokenChanged() {
                                trayPopup.close();
                            }
                        }
                    }
                }
            }
        }
    }

    // Battery Pill
    StyledRect {
        id: batteryPill
        height: root.pillHeight
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
            onEntered: batteryPill.rectOpacity = 1.0
            onExited: batteryPill.rectOpacity = ThemeService.bgOpacity
        }

        PopupWindow {
            id: batteryPopup
            property int popupWidth: 306
            property int popupPadding: 10
            property real popupOpacity: 0
            property real popupScale: 0.94
            property var profileActions: [
                { icon: "󰌪", label: "Power Saver", color: ThemeService.secondary, action: "power-saver" },
                { icon: "󰗑", label: "Balanced", color: ThemeService.primary, action: "balanced" },
                { icon: "󰓅", label: "Performance", color: ThemeService.warning, action: "performance" }
            ]

            anchor.item: batteryPill
            anchor.rect.x: batteryPill.width - implicitWidth
            anchor.rect.y: batteryPill.height + ThemeService.spacingMedium
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
                        model: batteryPopup.profileActions

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
                id: batteryPopupCloseTimer
                interval: ThemeService.animDuration + 50
                onTriggered: batteryPopup.visible = false
            }

            function open() {
                if (visible) return;
                root.closeTrayPopups();
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
                batteryPopupCloseTimer.restart();
            }

            function toggle() {
                if (visible) close();
                else open();
            }

            Connections {
                target: root
                function onCloseTrayPopupsTokenChanged() {
                    batteryPopup.close();
                }
            }
        }
    }

    // Stats & Clock Pill
    StyledRect {
        id: statsPill
        height: root.pillHeight
        width: statsRow.implicitWidth + ThemeService.radiusLarge
        radius: height / 2
        rectColor: ThemeService.background
        rectOpacity: ThemeService.bgOpacity
        borderOpacityValue: 0.0
        
        Row {
            id: statsRow
            anchors.centerIn: parent
            spacing: ThemeService.spacingLarge
            Text {
                text: ClockService.time
                font.family: ThemeService.fontName
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: ThemeService.foreground
            }
        }
    }

    // Power Pill
    StyledRect {
        id: powerPill
        height: root.pillHeight
        width: height
        radius: height / 2
        rectColor: ThemeService.background
        rectOpacity: ThemeService.bgOpacity
        borderOpacityValue: 0.0
        
        Text {
            anchors.centerIn: parent
            text: ""
            font.pixelSize: 14
            color: ThemeService.danger
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            // Use onPressed for immediate reaction
            onPressed: {
                root.requestIslandState(root.islandState === "powerMenu" ? "windowTitle" : "powerMenu");
            }
            onEntered: powerPill.rectOpacity = 1.0
            onExited: powerPill.rectOpacity = ThemeService.bgOpacity
        }
    }
}
