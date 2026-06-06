import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import "../services"
import "../components"

PanelWindow {
    id: barWindow

    anchors {
        top: true
        left: true
        right: true
    }

    // The total vertical length (height) of the bar from the top of the screen.
    property int barTotalHeight: 40
    // Explicit height for the side groups (Left/Right)
    property int sideCapsuleHeight: 35

    // FIXED WINDOW HEIGHT to prevent flickering
    implicitHeight: 450
    color: "transparent"

    exclusiveZone: barTotalHeight + 8
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Top

    // Precise mask using a single item container.
    mask: Region {
        item: maskHitboxContainer
    }

    Item {
        id: maskHitboxContainer
        anchors.fill: parent
        visible: false

        // Left Group Hitbox
        Rectangle {
            x: leftGroup.x; y: leftGroup.y
            width: leftGroup.width; height: leftGroup.height
            color: "white"
        }
        
        // Dynamic Island Hitbox
        Rectangle {
            x: dynamicIsland.x + 20; y: dynamicIsland.y
            width: dynamicIsland.width - 40; height: dynamicIsland.height
            color: "white"
        }
        
        // Right Group Hitbox
        Rectangle {
            x: rightGroup.x; y: rightGroup.y
            width: rightGroup.width; height: rightGroup.height
            color: "white"
        }
    }

    property string islandState: "windowTitle"
    property bool startupCompleted: false
    readonly property var activePlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    Timer {
        id: startupTimer
        interval: 1500
        running: true
        onTriggered: startupCompleted = true
    }

    // Main Content
    Item {
        id: mainBarContent
        anchors.fill: parent

        LeftGroup {
            id: leftGroup
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.top: parent.top
            anchors.topMargin: barWindow.barTotalHeight - barWindow.sideCapsuleHeight
            pillHeight: barWindow.sideCapsuleHeight
        }

        DynamicIsland {
            id: dynamicIsland
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 0
            baseHeight: barWindow.barTotalHeight
            
            islandState: barWindow.islandState
            activePlayer: barWindow.activePlayer
            triggerPower: barWindow.triggerPower
            onIslandStateChanged: barWindow.islandState = islandState
        }

        RightGroup {
            id: rightGroup
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.top: parent.top
            anchors.topMargin: barWindow.barTotalHeight - barWindow.sideCapsuleHeight
            pillHeight: barWindow.sideCapsuleHeight
            
            islandState: barWindow.islandState
            onIslandStateChanged: barWindow.islandState = islandState
        }
    }

    // Global event handlers to trigger island HUDs
    Connections {
        target: AudioService
        function onVolumeChanged() { if (startupCompleted) dynamicIsland.triggerIsland("volume"); }
        function onMutedChanged() { if (startupCompleted) dynamicIsland.triggerIsland("volume"); }
    }

    Connections {
        target: BatteryService
        function onIsPluggedInChanged() { if (startupCompleted) dynamicIsland.triggerIsland("battery"); }
    }

    function triggerPower(action) {
        let p = Qt.createQmlObject('import Quickshell.Io; Process { }', barWindow);
        if (action === "shutdown") p.command = ["systemctl", "poweroff"];
        else if (action === "reboot") p.command = ["reboot"];
        else if (action === "logout") p.command = ["hyprctl", "dispatch", "exit"];
        p.onExited.connect(() => p.destroy());
        p.running = true;
        barWindow.islandState = "windowTitle";
    }
}
