import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../services"
import "../components"

Row {
    id: root
    spacing: ThemeService.spacingMedium
    
    property int pillHeight: ThemeService.sideCapsuleHeight
    property alias islandState: root._islandState
    property string _islandState: ""

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
                IconImage {
                    required property var modelData
                    source: modelData.icon
                    width: ThemeService.iconSizeTray
                    height: width
                    smooth: true
                    MouseArea {
                        anchors.fill: parent
                        onClicked: event => {
                            if (event.button === Qt.LeftButton) modelData.activate();
                        }
                    }
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
            Row {
                spacing: ThemeService.spacingSmall
                Text { text: ""; font.pixelSize: 12; color: ThemeService.secondary }
                Text { text: Math.round(BatteryService.percentage) + "%"; font.family: ThemeService.fontName; font.pixelSize: 11; color: ThemeService.foreground }
            }
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
                if (root.islandState === "powerMenu") root.islandState = "windowTitle";
                else root.islandState = "powerMenu";
            }
            onEntered: powerPill.rectOpacity = 1.0
            onExited: powerPill.rectOpacity = ThemeService.bgOpacity
        }
    }
}
