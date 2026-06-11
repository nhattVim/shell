import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Services.Mpris
import "../services"
import "../components"
import "dashboard"

Item {
    id: root
    anchors.fill: parent
    clip: true

    signal requestClose()
    property var activePlayer: null

    readonly property bool hasPlayer: activePlayer !== null && activePlayer !== undefined
    readonly property bool isPlaying: activePlayer?.playbackState === MprisPlaybackState.Playing
    readonly property string wallpaperPath: WallpaperService.currentWallpaper ? "file://" + WallpaperService.currentWallpaper : ""
    readonly property string artworkSource: (activePlayer?.trackArtUrl ?? "") !== "" ? activePlayer.trackArtUrl : ""
    readonly property string mediaSource: artworkSource !== "" ? artworkSource : wallpaperPath

    Timer {
        running: root.isPlaying && root.visible
        interval: 1000
        repeat: true
        onTriggered: root.activePlayer?.positionChanged()
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.ArrowCursor
        onPressed: mouse => mouse.accepted = true
    }

    StyledRect {
        anchors.fill: parent
        anchors.margins: 8
        radius: ThemeService.radiusLarge
        rectColor: ThemeService.background
        rectOpacity: 1.0
        borderOpacityValue: 0.0
        clip: true

        Item {
            id: dashboardGrid
            anchors.fill: parent
            anchors.margins: 8

            readonly property int gap: 8
            readonly property int railWidth: 64
            readonly property int mediaWidth: 216
            readonly property int widgetsWidth: 272
            readonly property int notificationWidth: 268
            readonly property int volumeWidth: 56

            DashboardRail {
                x: 0
                y: 0
                width: dashboardGrid.railWidth
                height: dashboardGrid.height
                onRequestClose: root.requestClose()
            }

            MediaDialCard {
                x: dashboardGrid.railWidth + dashboardGrid.gap
                y: 0
                width: dashboardGrid.mediaWidth
                height: dashboardGrid.height
                activePlayer: root.activePlayer
                mediaSource: root.mediaSource
            }

            ColumnLayout {
                x: dashboardGrid.railWidth + dashboardGrid.mediaWidth + dashboardGrid.gap * 2
                y: 0
                width: dashboardGrid.widgetsWidth
                height: dashboardGrid.height
                spacing: 8

                ToggleStrip {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                }

                CalendarPanel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }

            NotificationsPanel {
                x: dashboardGrid.railWidth + dashboardGrid.mediaWidth + dashboardGrid.widgetsWidth + dashboardGrid.gap * 3
                y: 0
                width: dashboardGrid.notificationWidth
                height: dashboardGrid.height
            }

            VolumeRail {
                x: dashboardGrid.railWidth + dashboardGrid.mediaWidth + dashboardGrid.widgetsWidth + dashboardGrid.notificationWidth + dashboardGrid.gap * 4
                y: 0
                width: dashboardGrid.volumeWidth
                height: dashboardGrid.height
            }
        }
    }
}
