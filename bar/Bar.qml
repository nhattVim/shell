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

    // FIXED WINDOW HEIGHT
    implicitHeight: ThemeService.barMaxHeight
    color: "transparent"

    exclusiveZone: ThemeService.barTotalHeight
    exclusionMode: ExclusionMode.Ignore

    // Robust keyboard focus logic (Exclusive for menus to match ambxst)
    WlrLayershell.keyboardFocus: (islandState !== "windowTitle" && islandState !== "volume") ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Top

    // DYNAMIC MASK
    mask: Region {
        item: (islandState !== "windowTitle" && islandState !== "volume") ? fullWindowHitbox : null
        regions: [
            Region { item: leftGroup },
            Region { item: dynamicIsland },
            Region { item: rightGroup }
        ]
    }

    // --- VISIBLE UI LAYER ---
    Item {
        id: mainBarContent
        anchors.fill: parent

        // Click-outside detector
        MouseArea {
            id: clickOutsideDetector
            anchors.fill: parent
            enabled: barWindow.islandState !== "windowTitle" && barWindow.islandState !== "volume"
            onPressed: barWindow.islandState = "windowTitle"
            z: -1 
        }

        LeftGroup {
            id: leftGroup
            anchors.left: parent.left
            anchors.leftMargin: ThemeService.barMargin
            anchors.top: parent.top
            anchors.topMargin: ThemeService.barTotalHeight - ThemeService.sideCapsuleHeight
            pillHeight: ThemeService.sideCapsuleHeight
        }

        DynamicIsland {
            id: dynamicIsland
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 0
            baseHeight: ThemeService.barTotalHeight
            
            islandState: barWindow.islandState
            activePlayer: barWindow.activePlayer
            triggerPower: barWindow.triggerPower
            triggerProfile: barWindow.triggerProfile
            
            onIslandStateChanged: barWindow.islandState = islandState
        }

        RightGroup {
            id: rightGroup
            anchors.right: parent.right
            anchors.rightMargin: ThemeService.barMargin
            anchors.top: parent.top
            anchors.topMargin: ThemeService.barTotalHeight - ThemeService.sideCapsuleHeight
            pillHeight: ThemeService.sideCapsuleHeight
            
            islandState: barWindow.islandState
            onIslandStateChanged: barWindow.islandState = islandState
        }
    }


    Item {
        id: fullWindowHitbox
        anchors.fill: parent
        visible: true
        opacity: 0
        Rectangle { anchors.fill: parent; color: "white" }
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

    // Global event handlers
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
        if (action === "close") { barWindow.islandState = "windowTitle"; return; }
        let p = Qt.createQmlObject('import Quickshell.Io; Process { }', barWindow);
        if (action === "shutdown") p.command = ["systemctl", "poweroff"];
        else if (action === "reboot") p.command = ["reboot"];
        else if (action === "logout") p.command = ["hyprctl", "dispatch", "exit"];
        p.onExited.connect(() => p.destroy());
        p.running = true;
        barWindow.islandState = "windowTitle";
    }

    function triggerProfile(profile) {
        if (profile === "close") { barWindow.islandState = "windowTitle"; return; }
        let p = Qt.createQmlObject('import Quickshell.Io; Process { }', barWindow);
        p.command = ["powerprofilesctl", "set", profile];
        p.onExited.connect(() => p.destroy());
        p.running = true;
        barWindow.islandState = "windowTitle";
    }
}
