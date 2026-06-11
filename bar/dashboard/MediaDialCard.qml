import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../../services"

PanelFrame {
    id: root

    property var activePlayer: null
    property string mediaSource: ""

    readonly property bool hasPlayer: activePlayer !== null && activePlayer !== undefined
    readonly property bool isPlaying: activePlayer?.playbackState === MprisPlaybackState.Playing
    readonly property real position: activePlayer?.position ?? 0
    readonly property real length: activePlayer?.length ?? 1

    border.color: ThemeService.border
    color: ThemeService.surface

    function formatTime(value) {
        var totalSeconds = Math.max(0, Math.floor(value));
        var minutes = Math.floor(totalSeconds / 60);
        var seconds = totalSeconds % 60;
        return minutes + ":" + String(seconds).padStart(2, "0");
    }

    Image {
        anchors.fill: parent
        source: root.mediaSource
        fillMode: Image.PreserveAspectCrop
        visible: root.mediaSource !== ""
        asynchronous: true
        mipmap: true
        opacity: 0.42
    }

    Rectangle {
        anchors.fill: parent
        color: ThemeService.background
        opacity: 0.38
    }

    Canvas {
        id: progressRing
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 22
        width: 172
        height: 122
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.lineWidth = 6;
            ctx.lineCap = "round";
            ctx.strokeStyle = ThemeService.foreground;
            ctx.globalAlpha = 0.95;
            ctx.beginPath();
            ctx.arc(width / 2, 88, 74, Math.PI * 1.04, Math.PI * 1.96, false);
            ctx.stroke();

            var progress = root.hasPlayer && root.length > 0 ? Math.max(0, Math.min(1, root.position / root.length)) : 0.08;
            ctx.strokeStyle = ThemeService.primary;
            ctx.beginPath();
            ctx.arc(width / 2, 88, 74, Math.PI * 1.04, Math.PI * (1.04 + 0.92 * progress), false);
            ctx.stroke();
        }

        Connections {
            target: root
            function onPositionChanged() { progressRing.requestPaint(); }
            function onLengthChanged() { progressRing.requestPaint(); }
        }
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 44
        width: 122
        height: 122

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: ThemeService.surfaceBright
            border.width: 1
            border.color: ThemeService.border
            clip: true

            Image {
                anchors.fill: parent
                source: root.mediaSource
                fillMode: Image.PreserveAspectCrop
                visible: root.mediaSource !== ""
                asynchronous: true
                mipmap: true
            }

            Rectangle {
                anchors.fill: parent
                color: ThemeService.background
                opacity: root.mediaSource === "" ? 0.0 : 0.22
            }
        }

        Text {
            anchors.centerIn: parent
            text: "AMBXST"
            font.family: ThemeService.fontName
            font.pixelSize: 14
            font.weight: Font.Black
            color: ThemeService.textBright
            rotation: -18
            opacity: 0.92
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 8

        Text {
            Layout.fillWidth: true
            text: root.hasPlayer ? (root.activePlayer.trackTitle || "Unknown Title") : "Nothing Playing"
            font.family: ThemeService.fontName
            font.pixelSize: 15
            font.weight: Font.Bold
            color: ThemeService.textBright
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: root.hasPlayer ? (root.activePlayer.trackArtist || root.activePlayer.identity || "Player") : "Enjoy the silence"
            font.family: ThemeService.fontName
            font.pixelSize: 12
            color: ThemeService.primary
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: "\\_(ツ)_/"
            font.family: ThemeService.fontName
            font.pixelSize: 15
            color: ThemeService.foreground
            horizontalAlignment: Text.AlignHCenter
            opacity: root.hasPlayer ? 0.0 : 0.95
            visible: opacity > 0
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 12

            TextButton {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                icon: "󰋋"
                enabledState: false
            }
            TextButton {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                icon: "󰒮"
                enabledState: root.hasPlayer && root.activePlayer.canGoPrevious
                onClicked: root.activePlayer.previous()
            }
            TextButton {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                icon: root.isPlaying ? "󰏤" : "󰐊"
                filled: true
                enabledState: root.hasPlayer
                onClicked: root.activePlayer.togglePlaying()
            }
            TextButton {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                icon: "󰒭"
                enabledState: root.hasPlayer && root.activePlayer.canGoNext
                onClicked: root.activePlayer.next()
            }
            TextButton {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                icon: "󰒝"
                enabledState: false
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.hasPlayer ? root.formatTime(root.position) + " / " + root.formatTime(root.length) : "--:-- / --:--"
            font.family: ThemeService.fontName
            font.pixelSize: 11
            color: ThemeService.textDim
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
