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

    // Dynamic height to avoid blocking desktop clicks
    implicitHeight: (dynamicIsland.isHovered || islandState === "powerMenu") ? 400 : 60
    color: "transparent"

    exclusiveZone: 44
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Top

    // Precise mask tracking the pills
    mask: Region {
        item: mainBarContent
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
            anchors.leftMargin: 16
            anchors.top: parent.top
            anchors.topMargin: 5
        }

        DynamicIsland {
            id: dynamicIsland
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            islandState: barWindow.islandState
            activePlayer: barWindow.activePlayer
            triggerPower: barWindow.triggerPower
            
            // Expose internal hover state for implicitHeight calculation
            property bool isHovered: centerCapsule.isHovered
            
            onIslandStateChanged: barWindow.islandState = islandState
        }

        RightGroup {
            id: rightGroup
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.top: parent.top
            anchors.topMargin: 5
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
