import QtQuick
import "../services"

Column {
    id: root
    spacing: 20
    anchors.fill: parent
    anchors.margins: 20

    property var activePlayer: null

    Text {
        text: "Dashboard"
        font.family: ThemeService.fontName
        font.pixelSize: 16
        font.bold: true
        color: ThemeService.primary
    }

    Row {
        spacing: 20
        width: parent.width
        
        // Media Info
        Column {
            spacing: 8
            width: parent.width * 0.6
            Text {
                text: activePlayer ? activePlayer.trackTitle : "No Media"
                color: "white"
                font.family: ThemeService.fontName
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
            }
            Text {
                text: activePlayer ? activePlayer.trackArtist : "Select a player"
                color: ThemeService.textDim
                font.family: ThemeService.fontName
                font.pixelSize: 12
            }
            Row {
                spacing: 25
                Text { text: "⏮"; color: "white"; font.pixelSize: 18 }
                Text { text: ""; color: ThemeService.primary; font.pixelSize: 22 }
                Text { text: "⏭"; color: "white"; font.pixelSize: 18 }
            }
        }

        // Stats Grid
        Grid {
            columns: 2
            spacing: 15
            Column {
                Text { text: "CPU"; color: ThemeService.textDim; font.family: ThemeService.fontName; font.pixelSize: 10 }
                Text { text: "12%"; color: ThemeService.secondary; font.family: ThemeService.fontName; font.bold: true }
            }
            Column {
                Text { text: "RAM"; color: ThemeService.textDim; font.family: ThemeService.fontName; font.pixelSize: 10 }
                Text { text: "2.4G"; color: ThemeService.primary; font.family: ThemeService.fontName; font.bold: true }
            }
        }
    }
}
