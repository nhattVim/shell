import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import "../../services"
import "../../config"
import "../bar/groups"

PanelWindow {
    id: barWindow

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    exclusionMode: ExclusionMode.Ignore

    // Robust keyboard focus logic (Exclusive for menus to match ambxst)
    readonly property bool islandOverlayOpen: islandState !== "windowTitle"

    WlrLayershell.keyboardFocus: islandOverlayOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Top

    Item {
        id: fullScreenHitbox
        anchors.fill: parent
    }

    // DYNAMIC MASK
    mask: Region {
        item: islandOverlayOpen ? fullScreenHitbox : null
        regions: [
            Region { item: leftGroup },
            Region { item: dynamicIsland },
            Region { item: rightGroup }
        ]
    }

    MouseArea {
        id: clickOutsideDetector
        anchors.fill: parent
        visible: barWindow.islandOverlayOpen
        z: -1
        onPressed: barWindow.islandState = "windowTitle"
    }

    // --- VISIBLE UI LAYER ---
    Item {
        id: mainBarContent
        anchors.fill: parent

        LeftGroup {
            id: leftGroup
            anchors.left: parent.left
            anchors.leftMargin: ThemeService.barMargin
            anchors.top: parent.top
            anchors.topMargin: ThemeService.barTotalHeight - ThemeService.sideCapsuleHeight
            pillHeight: ThemeService.sideCapsuleHeight
        }

        CenterIsland {
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

    property string islandState: "windowTitle"
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
