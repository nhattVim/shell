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
    readonly property bool islandOverlayOpen: islandState !== "windowTitle" && islandState !== "volume"

    WlrLayershell.keyboardFocus: islandOverlayOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Top

    // DYNAMIC MASK
    mask: Region {
        item: islandOverlayOpen ? fullWindowHitbox : null
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
            enabled: barWindow.islandOverlayOpen
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
            
            onRequestIslandState: state => barWindow.islandState = state
        }

        RightGroup {
            id: rightGroup
            anchors.right: parent.right
            anchors.rightMargin: ThemeService.barMargin
            anchors.top: parent.top
            anchors.topMargin: ThemeService.barTotalHeight - ThemeService.sideCapsuleHeight
            pillHeight: ThemeService.sideCapsuleHeight
            
            islandState: barWindow.islandState
            triggerProfile: barWindow.triggerProfile
            onRequestIslandState: state => barWindow.islandState = state
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
    function chooseActivePlayer() {
        const players = Mpris.players.values || [];
        if (players.length === 0) return null;

        const playingPlayer = players.find(player => player.playbackState === MprisPlaybackState.Playing);
        if (playingPlayer) return playingPlayer;

        const nonFirefoxPlayer = players.find(player => {
            const dbusName = (player.dbusName || "").toLowerCase();
            return !dbusName.includes("firefox");
        });
        if (nonFirefoxPlayer) return nonFirefoxPlayer;

        return players[0];
    }

    readonly property var activePlayer: chooseActivePlayer()

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
        PowerProfileService.setProfile(profile);
        barWindow.islandState = "windowTitle";
    }
}
