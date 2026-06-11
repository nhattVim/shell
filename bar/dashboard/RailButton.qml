import QtQuick
import "../../services"

Item {
    id: root

    property string icon: ""
    property bool selected: false
    property color accent: ThemeService.primary

    Rectangle {
        anchors.centerIn: parent
        width: root.selected ? 48 : 42
        height: root.selected ? 48 : 42
        radius: root.selected ? 18 : 16
        color: root.selected ? root.accent : ThemeService.surfaceBright
        opacity: root.selected ? 1.0 : 0.86
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: ThemeService.iconFont
        font.pixelSize: 18
        color: root.selected ? ThemeService.background : root.accent
    }
}
