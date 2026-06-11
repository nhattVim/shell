import QtQuick
import "../../../services"
import "../../../config"
import "../../../components"

StyledRect {
    id: root

    property int pillHeight: ThemeService.sideCapsuleHeight
    property string islandState: ""

    signal requestIslandState(string state)

    height: pillHeight
    width: height
    radius: height / 2
    rectColor: ThemeService.background
    rectOpacity: ThemeService.bgOpacity
    borderOpacityValue: 0.0

    Text {
        anchors.centerIn: parent
        text: ""
        font.pixelSize: 14
        color: ThemeService.danger
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: root.requestIslandState(root.islandState === "powerMenu" ? "windowTitle" : "powerMenu")
        onEntered: root.rectOpacity = 1.0
        onExited: root.rectOpacity = ThemeService.bgOpacity
    }
}
