import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"
import "../components"

Item {
    id: root
    width: centerCapsule.width + (20 * 2)
    height: centerCapsule.height

    property int baseHeight: ThemeService.barTotalHeight
    property alias islandState: root._islandState
    property string _islandState: "windowTitle"
    property var activePlayer: null
    property var triggerPower: null

    // Left "Ear" (Concave Corner)
    RoundCorner {
        anchors.right: centerCapsule.left
        anchors.top: parent.top
        size: 20
        corner: RoundCorner.CornerEnum.TopRight
        color: ThemeService.background
    }
    
    // Right "Ear" (Concave Corner)
    RoundCorner {
        anchors.left: centerCapsule.right
        anchors.top: parent.top
        size: 20
        corner: RoundCorner.CornerEnum.TopLeft
        color: ThemeService.background
    }

    StyledRect {
        id: centerCapsule
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        clip: true
        rectColor: ThemeService.background
        rectOpacity: ThemeService.bgOpacityHigh
        borderOpacityValue: 0.0
        
        property bool isHovered: false
        
        onIsHoveredChanged: {
            if (isHovered) {
                islandTimer.stop();
            } else {
                if (root.islandState !== "powerMenu" && root.islandState !== "media") islandTimer.restart();
            }
        }
        
        height: {
            if (root.islandState === "powerMenu") return 200;
            if (root.islandState === "media") return ThemeService.islandDashboardHeight;
            if (root.islandState !== "windowTitle") return 48; 
            return root.baseHeight;
        }
        
        width: {
            if (root.islandState === "powerMenu") return 400;
            if (root.islandState === "media") return ThemeService.islandDashboardWidth;
            if (root.islandState === "volume") return 210;
            return ThemeService.islandWidth;
        }
        
        topLeftRadiusVal: 0
        topRightRadiusVal: 0
        bottomLeftRadiusVal: (root.islandState === "media" || root.islandState === "powerMenu") ? 24 : 19
        bottomRightRadiusVal: (root.islandState === "media" || root.islandState === "powerMenu") ? 24 : 19
        
        Behavior on width { NumberAnimation { duration: ThemeService.animDuration + 100; easing.type: Easing.OutExpo } }
        Behavior on height { NumberAnimation { duration: ThemeService.animDuration + 100; easing.type: Easing.OutExpo } }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: centerCapsule.isHovered = true
            onExited: centerCapsule.isHovered = false
        }

        Item {
            anchors.fill: parent
            
            // 1. COLLAPSED VIEW (High-Detail 3-Part Layout)
            Item {
                anchors.fill: parent
                visible: root.islandState !== "media" && root.islandState !== "powerMenu"
                
                Row {
                    anchors.centerIn: parent
                    width: parent.width - 16
                    spacing: 8

                    // LEFT: Dashboard Toggle
                    Item {
                        id: dashToggleItem
                        width: 32; height: 32
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰕮"
                            font.pixelSize: 16
                            color: dashToggleMouse.containsMouse ? ThemeService.primary : ThemeService.foreground
                            opacity: dashToggleMouse.containsMouse ? 1.0 : 0.8
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        MouseArea {
                            id: dashToggleMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.islandState = "media"
                        }
                    }

                    // SEPARATOR
                    Rectangle {
                        width: 2; height: 18
                        radius: 1
                        color: ThemeService.foreground
                        opacity: 0.2
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // CENTER: Large Title Frame (Premium Look)
                    StyledRect {
                        id: titleFrame
                        width: parent.width - (dashToggleItem.width + notifIndicatorItem.width + (parent.spacing * 2) + 4 + 16)
                        height: parent.height - 4 // Reduced margins from 8 to 4
                        radius: height / 2
                        anchors.verticalCenter: parent.verticalCenter
                        rectColor: ThemeService.surfaceBright
                        rectOpacity: 0.6 // More visible frame
                        borderOpacityValue: 0.15

                        Text {
                            id: titleText
                            anchors.centerIn: parent
                            text: root.islandState === "windowTitle" ? (WindowService.activeWindowTitle || "Desktop") : ""
                            color: "white"
                            font.family: ThemeService.fontName
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            visible: root.islandState === "windowTitle"
                            elide: Text.ElideRight
                            width: parent.width - 24
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Row {
                            anchors.centerIn: parent
                            visible: root.islandState === "volume"
                            spacing: 8
                            Text { text: AudioService.muted ? "" : ""; color: ThemeService.primary; font.pixelSize: 13 }
                            Rectangle { width: 120; height: 4; radius: 2; color: ThemeService.surface; Rectangle { width: parent.width * AudioService.volume; height: 4; radius: 2; color: ThemeService.primary } }
                        }
                    }

                    // SEPARATOR
                    Rectangle {
                        width: 2; height: 18
                        radius: 1
                        color: ThemeService.foreground
                        opacity: 0.2
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // RIGHT: Notifications
                    Item {
                        id: notifIndicatorItem
                        width: 32; height: 32
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "󰂚"
                            font.pixelSize: 16
                            color: ThemeService.foreground
                            opacity: 0.8
                        }
                    }
                }
            }
            
            PowerMenuContent {
                visible: root.islandState === "powerMenu"
                triggerPower: root.triggerPower
            }
            
            Item {
                anchors.fill: parent
                visible: root.islandState === "media"

                DashboardContent {
                    anchors.fill: parent
                    activePlayer: root.activePlayer
                }

                // Close button for dashboard
                MouseArea {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    width: 44; height: 44
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.islandState = "windowTitle"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        color: ThemeService.textDim
                        font.pixelSize: 18
                    }
                }
            }
        }
    }
    
    Timer {
        id: islandTimer
        interval: 3000
        running: false
        repeat: false
        onTriggered: if (root.islandState !== "media" && root.islandState !== "powerMenu") root.islandState = "windowTitle"
    }

    function triggerIsland(state) {
        root.islandState = state;
        islandTimer.restart();
    }
}
