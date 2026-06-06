import QtQuick
import "../services"

Column {
    id: root
    spacing: 20
    anchors.fill: parent
    anchors.margins: 20

    property var triggerPower: null

    Text {
        text: "Power Menu"
        font.family: ThemeService.fontName
        font.pixelSize: 16
        font.bold: true
        color: ThemeService.primary
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Row {
        spacing: 30
        anchors.horizontalCenter: parent.horizontalCenter
        
        Column {
            spacing: 10
            Text { text: ""; font.pixelSize: 32; color: "#ff5555"; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "Shutdown"; color: "white"; font.family: ThemeService.fontName; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter }
            MouseArea { anchors.fill: parent; onClicked: if (root.triggerPower) root.triggerPower("shutdown") }
        }
        Column {
            spacing: 10
            Text { text: ""; font.pixelSize: 32; color: "#ffb86c"; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "Reboot"; color: "white"; font.family: ThemeService.fontName; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter }
            MouseArea { anchors.fill: parent; onClicked: if (root.triggerPower) root.triggerPower("reboot") }
        }
        Column {
            spacing: 10
            Text { text: ""; font.pixelSize: 32; color: "#50fa7b"; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "Logout"; color: "white"; font.family: ThemeService.fontName; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter }
            MouseArea { anchors.fill: parent; onClicked: if (root.triggerPower) root.triggerPower("logout") }
        }
    }
}
