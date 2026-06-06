import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"
import "../components"

Item {
    id: root
    width: centerCapsule.width + (20 * 2)
    height: centerCapsule.height

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
                if (root.islandState === "windowTitle" && root.activePlayer !== null) {
                    root.islandState = "media";
                }
            } else {
                if (root.islandState !== "powerMenu") islandTimer.restart();
            }
        }
        
        height: {
            if (root.islandState === "powerMenu") return 200;
            if (isHovered) return ThemeService.islandDashboardHeight;
            if (root.islandState !== "windowTitle") return 44;
            return ThemeService.barHeight;
        }
        
        width: {
            if (root.islandState === "powerMenu") return 400;
            if (isHovered) return ThemeService.islandDashboardWidth;
            if (root.islandState === "volume") return 210;
            if (root.islandState === "media") return 250;
            return ThemeService.islandWidth;
        }
        
        topLeftRadiusVal: 0
        topRightRadiusVal: 0
        bottomLeftRadiusVal: (isHovered || root.islandState === "powerMenu") ? 24 : 18
        bottomRightRadiusVal: (isHovered || root.islandState === "powerMenu") ? 24 : 18
        
        Behavior on width { NumberAnimation { duration: ThemeService.animDuration + 100; easing.type: Easing.OutExpo } }
        Behavior on height { NumberAnimation { duration: ThemeService.animDuration + 100; easing.type: Easing.OutExpo } }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: centerCapsule.isHovered = true
            onExited: centerCapsule.isHovered = false
        }

        Item {
            anchors.fill: parent
            
            // 1. COLLAPSED VIEW
            Item {
                anchors.fill: parent
                visible: !centerCapsule.isHovered && root.islandState !== "powerMenu"
                
                Text {
                    id: titleText
                    anchors.centerIn: parent
                    text: root.islandState === "windowTitle" ? (WindowService.activeWindowTitle || "Desktop") : ""
                    color: ThemeService.foreground
                    font.family: ThemeService.fontName
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    visible: root.islandState === "windowTitle"
                    elide: Text.ElideRight
                    width: parent.width - 20
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Row {
                    anchors.centerIn: parent
                    visible: root.islandState === "volume"
                    spacing: 10
                    Text {
                        text: AudioService.muted ? "" : ""
                        color: ThemeService.primary
                        font.pixelSize: 12
                    }
                    Rectangle {
                        width: 100
                        height: 4
                        radius: 2
                        color: ThemeService.surfaceBright
                        Rectangle {
                            width: parent.width * AudioService.volume
                            height: 4
                            radius: 2
                            color: ThemeService.primary
                        }
                    }
                }
            }
            
            // 2. POWER MENU VIEW
            PowerMenuContent {
                visible: root.islandState === "powerMenu"
                triggerPower: root.triggerPower
            }
            
            // 3. DASHBOARD VIEW
            DashboardContent {
                visible: centerCapsule.isHovered && root.islandState !== "powerMenu"
                activePlayer: root.activePlayer
            }
        }
    }
    
    Timer {
        id: islandTimer
        interval: 3000
        running: false
        repeat: false
        onTriggered: root.islandState = "windowTitle"
    }

    function triggerIsland(state) {
        root.islandState = state;
        islandTimer.restart();
    }
}
