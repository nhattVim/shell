import QtQuick
import QtQuick.Layouts
import "../../../services"
import "../../../config"

Item {
    id: root

    Rectangle {
        anchors.fill: parent
        radius: 28
        color: ThemeService.background
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 7
        spacing: 10

        RailButton {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignHCenter
            icon: "󰖨"
            selected: false
            accent: ThemeService.primary
        }

        Item {
            id: volumeSlider

            Layout.fillWidth: true
            Layout.fillHeight: true

            readonly property int trackPadding: 8
            readonly property real currentVolume: AudioService.ready ? AudioService.volume : 0
            readonly property real trackHeight: Math.max(1, height - trackPadding * 2)

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: volumeSlider.trackPadding
                anchors.bottomMargin: volumeSlider.trackPadding
                width: 4
                radius: 2
                color: ThemeService.surfaceBright
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: volumeSlider.trackPadding
                width: 4
                height: volumeSlider.trackHeight * volumeSlider.currentVolume
                radius: 2
                color: ThemeService.primary
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: volumeSlider.trackPadding + volumeSlider.trackHeight * (1 - volumeSlider.currentVolume) - height / 2
                width: 16
                height: 5
                radius: 2
                color: ThemeService.textBright
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse => updateVolume(mouse.y)
                onPositionChanged: mouse => {
                    if (pressed) updateVolume(mouse.y);
                }
                onWheel: wheel => {
                    var step = wheel.angleDelta.y > 0 ? 0.04 : -0.04;
                    AudioService.changeVolume(step);
                    wheel.accepted = true;
                }
            }
        }

        RailButton {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignHCenter
            icon: AudioService.muted ? "󰝟" : "󰕾"
            selected: true
            accent: ThemeService.primary

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: AudioService.toggleMute()
            }
        }

        RailButton {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignHCenter
            icon: "󰍭"
            selected: false
            accent: ThemeService.primary

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NetworkService.rescan()
            }
        }
    }

    function updateVolume(yPos) {
        if (!AudioService.ready) return;
        var trackTop = volumeSlider.trackPadding;
        var trackHeight = volumeSlider.trackHeight;
        var localY = Math.max(0, Math.min(trackHeight, yPos - trackTop));
        var value = 1 - localY / trackHeight;
        AudioService.setVolume(value);
    }
}
