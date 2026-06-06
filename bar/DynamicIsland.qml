import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"
import "../components"

Item {
    id: root
    width: centerCapsule.width + (20 * 2)
    height: centerCapsule.height

    property int baseHeight: ThemeService.barHeight
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
            if (root.islandState !== "windowTitle") return 48; // HUD for slimmer bar
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
            
            // 1. COLLAPSED VIEW (3-Part Layout like ambxst)
            Item {
                anchors.fill: parent
                visible: root.islandState !== "media" && root.islandState !== "powerMenu"
                
                Row {
                    anchors.centerIn: parent
                    width: parent.width - 32
                    spacing: 12

                    // LEFT: Dashboard Toggle
                    Item {
                        width: 28; height: 28
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰕮"
                            font.pixelSize: 14
                            color: dashToggleMouse.containsMouse ? ThemeService.primary : ThemeService.foreground
                            opacity: dashToggleMouse.containsMouse ? 1.0 : 0.6
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

                    // CENTER: Window Title / HUD
                    Item {
                        width: parent.width - 100
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: root.islandState === "windowTitle" ? (WindowService.activeWindowTitle || "Desktop") : ""
                            color: ThemeService.foreground
                            font.family: ThemeService.fontName
                            font.pixelSize: 10
                            font.weight: Font.Medium
                            visible: root.islandState === "windowTitle"
                            elide: Text.ElideRight
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Row {
                            anchors.centerIn: parent
                            visible: root.islandState === "volume"
                            spacing: 8
                            Text { text: AudioService.muted ? "" : ""; color: ThemeService.primary; font.pixelSize: 12 }
                            Rectangle { width: 80; height: 3; radius: 1.5; color: ThemeService.surfaceBright; Rectangle { width: parent.width * AudioService.volume; height: 3; radius: 1.5; color: ThemeService.primary } }
                        }
                    }

                    // RIGHT: Notifications
                    Item {
                        width: 28; height: 28
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "󰂚"
                            font.pixelSize: 14
                            color: ThemeService.foreground
                            opacity: 0.6
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
                    width: 40; height: 40
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.islandState = "windowTitle"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        color: ThemeService.textDim
                        font.pixelSize: 16
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
