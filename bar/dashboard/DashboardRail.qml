import QtQuick
import "../../services"

Item {
    id: root
    signal requestClose()

    readonly property color accent: ThemeService.primary
    readonly property color panel: ThemeService.surface
    readonly property color dim: ThemeService.textDim

    Rectangle {
        anchors.fill: parent
        radius: 28
        color: ThemeService.background
    }

    Column {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 6
        spacing: 20

        RailButton {
            width: 48
            height: 48
            icon: "󰣇"
            selected: true
            accent: root.accent
        }

        RailButton {
            width: 48
            height: 36
            icon: "󰙯"
            accent: root.accent
        }

        RailButton {
            width: 48
            height: 36
            icon: "󱢠"
            accent: root.accent
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 68
        width: 1
        height: parent.height - 90
        color: ThemeService.border
        opacity: 0.65
    }

    RailButton {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        width: 48
        height: 48
        icon: "󰒓"
        accent: root.accent
        selected: closeArea.containsMouse

        MouseArea {
            id: closeArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.requestClose()
        }
    }
}
