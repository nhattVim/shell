import QtQuick
import "../services"

Column {
    id: root
    spacing: ThemeService.spacingExtraLarge
    anchors.fill: parent
    anchors.margins: ThemeService.spacingExtraLarge

    property var activePlayer: null

    Text {
        text: "Dashboard"
        font.family: ThemeService.fontName
        font.pixelSize: 16
        font.bold: true
        color: ThemeService.primary
    }

    Row {
        spacing: ThemeService.spacingExtraLarge
        width: parent.width
        
        // Media Info
        Column {
            spacing: ThemeService.spacingSmall
            width: parent.width * 0.6
            Text {
                text: activePlayer ? activePlayer.trackTitle : "No Media"
                color: ThemeService.textBright
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
                spacing: ThemeService.spacingExtraLarge
                Text { text: "⏮"; color: ThemeService.textBright; font.pixelSize: 18 }
                Text { text: ""; color: ThemeService.primary; font.pixelSize: 22 }
                Text { text: "⏭"; color: ThemeService.textBright; font.pixelSize: 18 }
            }
        }

        // Stats Grid
        Grid {
            columns: 2
            spacing: ThemeService.spacingLarge
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
