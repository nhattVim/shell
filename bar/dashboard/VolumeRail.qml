import QtQuick
import QtQuick.Layouts
import "../../services"

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
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                width: 4
                radius: 2
                color: ThemeService.surfaceBright
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                width: 4
                height: (parent.height - 16) * (AudioService.ready ? AudioService.volume : 0)
                radius: 2
                color: ThemeService.primary
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 8 + (parent.height - 16) * (1 - (AudioService.ready ? AudioService.volume : 0)) - height / 2
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
        var trackTop = 15;
        var trackHeight = Math.max(1, height - 30);
        var value = 1 - Math.max(0, Math.min(trackHeight, yPos - trackTop)) / trackHeight;
        AudioService.setVolume(value);
    }
}
