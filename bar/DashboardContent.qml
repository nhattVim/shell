import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Services.Mpris
import "../services"
import "../components"

Item {
    id: root
    anchors.fill: parent
    clip: true

    signal requestClose()
    property var activePlayer: null

    readonly property bool hasPlayer: activePlayer !== null
    readonly property bool isPlaying: activePlayer?.playbackState === MprisPlaybackState.Playing
    readonly property real position: activePlayer?.position ?? 0.0
    readonly property real length: activePlayer?.length ?? 1.0
    readonly property bool hasArtwork: (activePlayer?.trackArtUrl ?? "") !== ""
    readonly property string wallpaperPath: WallpaperService.currentWallpaper ? "file://" + WallpaperService.currentWallpaper : ""
    readonly property string mediaSource: hasArtwork ? activePlayer.trackArtUrl : wallpaperPath

    function profileLabel(profile) {
        if (profile === "power-saver") return "Saver";
        if (profile === "performance") return "Performance";
        return "Balanced";
    }

    function wifiValue() {
        if (!NetworkService.wifiEnabled) return "Off";
        if (NetworkService.wifiConnected) return NetworkService.wifiName;
        return "No network";
    }

    function batteryValue() {
        if (!BatteryService.available) return "Unavailable";
        return Math.round(BatteryService.percentage) + "%";
    }

    function batteryIcon() {
        if (!BatteryService.available) return "󰂎";
        if (BatteryService.isCharging) return "󰂄";
        if (BatteryService.percentage >= 90) return "󰁹";
        if (BatteryService.percentage >= 75) return "󰂂";
        if (BatteryService.percentage >= 50) return "󰁾";
        if (BatteryService.percentage >= 25) return "󰁻";
        return "󰁺";
    }

    function volumeIcon() {
        if (AudioService.muted || !AudioService.ready) return "󰝟";
        if (AudioService.volume >= 0.67) return "󰕾";
        if (AudioService.volume >= 0.34) return "󰖀";
        return "󰕿";
    }

    function volumeLabel() {
        if (!AudioService.ready) return "No sink";
        if (AudioService.muted) return "Muted";
        return Math.round(AudioService.volume * 100) + "%";
    }

    function placeholderIcon(name) {
        return name;
    }

    Timer {
        running: root.isPlaying && root.visible
        interval: 1000
        repeat: true
        onTriggered: root.activePlayer?.positionChanged()
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: root.mediaSource
        fillMode: Image.PreserveAspectCrop
        visible: false
        asynchronous: true
        mipmap: true
    }

    MultiEffect {
        anchors.fill: parent
        source: backgroundImage
        blurEnabled: root.mediaSource !== ""
        blurMax: 32
        blur: 1.0
        opacity: root.mediaSource !== "" ? 0.16 : 0.0
        visible: root.mediaSource !== ""
        Behavior on opacity {
            enabled: ThemeService.animDuration > 0
            NumberAnimation {
                duration: ThemeService.animDuration
                easing.type: Easing.OutQuart
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: ThemeService.background
        opacity: 0.78
    }

    Rectangle {
        anchors.fill: parent
        color: ThemeService.scrimColor
        opacity: 0.34
    }

    MouseArea {
        anchors.fill: parent
        z: 0
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.ArrowCursor
        onPressed: mouse => {
            const insideCard =
                mouse.x >= outerCard.x &&
                mouse.x <= outerCard.x + outerCard.width &&
                mouse.y >= outerCard.y &&
                mouse.y <= outerCard.y + outerCard.height;

            if (!insideCard) {
                mouse.accepted = true;
                root.requestClose();
            } else {
                mouse.accepted = false;
            }
        }
    }

    Item {
        id: contentLayer
        anchors.fill: parent
        anchors.margins: 16
        z: 1

        StyledRect {
            id: outerCard
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 0
            width: Math.min(parent.width, 900)
            height: contentColumn.implicitHeight + 28
            radius: ThemeService.radiusLarge
            rectColor: ThemeService.surface
            rectOpacity: 0.84
            borderOpacityValue: 0.18
            clip: true

            ColumnLayout {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 12
                z: 1

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Dashboard"
                            font.family: ThemeService.fontName
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: ThemeService.textBright
                        }

                        Text {
                            text: root.hasPlayer
                                ? ((root.activePlayer.trackTitle || "Unknown title") + " · " + (root.activePlayer.trackArtist || root.activePlayer.identity || "Player"))
                                : "Media and system overview"
                            font.family: ThemeService.fontName
                            font.pixelSize: 11
                            color: ThemeService.foreground
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    ColumnLayout {
                        spacing: 0
                        Layout.alignment: Qt.AlignRight

                        Text {
                            text: ClockService.time
                            font.family: ThemeService.fontName
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: ThemeService.textBright
                            horizontalAlignment: Text.AlignRight
                        }

                        Text {
                            text: ClockService.date
                            font.family: ThemeService.fontName
                            font.pixelSize: 11
                            color: ThemeService.foreground
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    StyledRect {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 340
                        radius: ThemeService.radiusLarge
                        rectColor: ThemeService.background
                        rectOpacity: 0.38
                        borderOpacityValue: 0.12

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: ThemeService.spacingSmall

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0

                                    Text {
                                        text: root.hasPlayer ? (root.activePlayer.trackTitle || "Nothing Playing") : "Nothing Playing"
                                        font.family: ThemeService.fontName
                                        font.pixelSize: 20
                                        font.weight: Font.Bold
                                        color: ThemeService.textBright
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: root.hasPlayer ? (root.activePlayer.trackAlbum || root.activePlayer.trackArtist || "") : "Enjoy the silence"
                                        font.family: ThemeService.fontName
                                        font.pixelSize: 11
                                        color: ThemeService.foreground
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                Rectangle {
                                    width: 88
                                    height: 28
                                    radius: 14
                                    color: ThemeService.surfaceBright
                                    opacity: 0.58

                                    Text {
                                        anchors.centerIn: parent
                                        text: root.hasPlayer ? root.profileLabel(PowerProfileService.activeProfile) : "Idle"
                                        font.family: ThemeService.fontName
                                        font.pixelSize: 10
                                        font.weight: Font.DemiBold
                                        color: root.hasPlayer ? ThemeService.textBright : ThemeService.foreground
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 168

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 84
                                    color: ThemeService.surfaceBright
                                    opacity: 0.95
                                }

                                Image {
                                    anchors.fill: parent
                                    source: root.mediaSource
                                    fillMode: Image.PreserveAspectCrop
                                    visible: root.mediaSource !== ""
                                    asynchronous: true
                                    mipmap: true
                                    layer.enabled: true
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 84
                                    color: ThemeService.background
                                    opacity: root.mediaSource === "" ? 0.94 : 0.18
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: root.hasPlayer ? "󰝚" : "󰍬"
                                    font.family: ThemeService.iconFont
                                    font.pixelSize: 40
                                    color: ThemeService.primary
                                    opacity: root.mediaSource === "" ? 1.0 : 0.0
                                    visible: opacity > 0
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 7
                                radius: 3.5
                                color: ThemeService.surfaceBright
                                opacity: 0.78

                                Rectangle {
                                    width: root.hasPlayer && root.length > 0 ? Math.max(0, Math.min(1, root.position / root.length)) * parent.width : 0
                                    height: parent.height
                                    radius: 3.5
                                    color: ThemeService.primary
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: root.hasPlayer ? Math.floor(root.position / 60) + ":" + String(Math.floor(root.position) % 60).padStart(2, "0") : "0:00"
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 10
                                    color: ThemeService.foreground
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: root.hasPlayer ? Math.floor(root.length / 60) + ":" + String(Math.floor(root.length) % 60).padStart(2, "0") : "0:00"
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 10
                                    color: ThemeService.foreground
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Item {
                                    width: 34
                                    height: 34
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 12
                                        color: ThemeService.surfaceBright
                                        opacity: prevArea.containsMouse ? 0.95 : 0.55
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰒮"
                                        font.family: ThemeService.iconFont
                                        font.pixelSize: 16
                                        color: root.hasPlayer && root.activePlayer.canGoPrevious ? ThemeService.textBright : ThemeService.foreground
                                        opacity: root.hasPlayer && root.activePlayer.canGoPrevious ? 1.0 : 0.4
                                    }
                                    MouseArea {
                                        id: prevArea
                                        anchors.fill: parent
                                        enabled: root.hasPlayer && root.activePlayer.canGoPrevious
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        onClicked: root.activePlayer.previous()
                                    }
                                }

                                Item {
                                    width: 44
                                    height: 44
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 16
                                        color: ThemeService.primary
                                        opacity: playArea.containsMouse ? 1.0 : 0.88
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: root.isPlaying ? "󰏤" : "󰐊"
                                        font.family: ThemeService.iconFont
                                        font.pixelSize: 20
                                        color: ThemeService.background
                                    }
                                    MouseArea {
                                        id: playArea
                                        anchors.fill: parent
                                        enabled: root.hasPlayer
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        onClicked: root.activePlayer.togglePlaying()
                                    }
                                }

                                Item {
                                    width: 34
                                    height: 34
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 12
                                        color: ThemeService.surfaceBright
                                        opacity: nextArea.containsMouse ? 0.95 : 0.55
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰒭"
                                        font.family: ThemeService.iconFont
                                        font.pixelSize: 16
                                        color: root.hasPlayer && root.activePlayer.canGoNext ? ThemeService.textBright : ThemeService.foreground
                                        opacity: root.hasPlayer && root.activePlayer.canGoNext ? 1.0 : 0.4
                                    }
                                    MouseArea {
                                        id: nextArea
                                        anchors.fill: parent
                                        enabled: root.hasPlayer && root.activePlayer.canGoNext
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        onClicked: root.activePlayer.next()
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                Rectangle {
                                    width: 72
                                    height: 24
                                    radius: 12
                                    color: ThemeService.surfaceBright
                                    opacity: 0.55

                                    Text {
                                        anchors.centerIn: parent
                                        text: root.hasPlayer ? (root.activePlayer.canSeek ? "Seek" : "Locked") : "No media"
                                        font.family: ThemeService.fontName
                                        font.pixelSize: 9
                                        font.weight: Font.DemiBold
                                        color: ThemeService.foreground
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 296
                        Layout.fillHeight: true
                        spacing: 8

                        StyledRect {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 112
                            radius: ThemeService.radiusMedium
                            rectColor: ThemeService.surfaceBright
                            rectOpacity: 0.3
                            borderOpacityValue: 0.1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Text {
                                    text: "Widgets"
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                    color: ThemeService.textBright
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Repeater {
                                        model: [
                                            { icon: "󰖩", label: "Wi-Fi" },
                                            { icon: "󰂄", label: "BT" },
                                            { icon: "󰍁", label: "Light" },
                                            { icon: "󰌪", label: "Caffe" },
                                            { icon: "󰓅", label: "Game" }
                                        ]

                                        delegate: Item {
                                            required property var modelData
                                            width: 48
                                            height: 48

                                            Rectangle {
                                                anchors.fill: parent
                                                radius: 14
                                                color: ThemeService.background
                                                opacity: 0.58
                                                border.width: 1
                                                border.color: ThemeService.surfaceBright
                                            }

                                            Column {
                                                anchors.centerIn: parent
                                                spacing: 2
                                                Text {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: modelData.icon
                                                    font.family: ThemeService.iconFont
                                                    font.pixelSize: 16
                                                    color: ThemeService.primary
                                                }
                                                Text {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: modelData.label
                                                    font.family: ThemeService.fontName
                                                    font.pixelSize: 8
                                                    color: ThemeService.foreground
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        StyledRect {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 188
                            radius: ThemeService.radiusMedium
                            rectColor: ThemeService.surfaceBright
                            rectOpacity: 0.3
                            borderOpacityValue: 0.1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 6

                                Text {
                                    text: "Calendar"
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                    color: ThemeService.textBright
                                }

                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 7
                                    columnSpacing: 4
                                    rowSpacing: 4

                                    Repeater {
                                        model: 28

                                        delegate: Rectangle {
                                            width: 28
                                            height: 24
                                            radius: 8
                                            color: index === 14 ? ThemeService.primary : ThemeService.background
                                            opacity: index === 14 ? 0.95 : 0.55
                                            border.width: 1
                                            border.color: ThemeService.surfaceBright

                                            Text {
                                                anchors.centerIn: parent
                                                text: index + 1
                                                font.family: ThemeService.fontName
                                                font.pixelSize: 9
                                                color: index === 14 ? ThemeService.background : ThemeService.foreground
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        StyledRect {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: ThemeService.radiusMedium
                            rectColor: ThemeService.surfaceBright
                            rectOpacity: 0.26
                            borderOpacityValue: 0.1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 6

                                Text {
                                    text: "Placeholder"
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                    color: ThemeService.textBright
                                }

                                Text {
                                    text: "Notes / extras / future widgets"
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 9
                                    color: ThemeService.foreground
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Item { Layout.fillHeight: true }

                                Text {
                                    text: "󰌷   󰦕   󰖙"
                                    font.family: ThemeService.iconFont
                                    font.pixelSize: 16
                                    color: ThemeService.primary
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 180
                        Layout.fillHeight: true
                        spacing: 8

                        StyledRect {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 214
                            radius: ThemeService.radiusMedium
                            rectColor: ThemeService.surfaceBright
                            rectOpacity: 0.3
                            borderOpacityValue: 0.1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 6

                                Text {
                                    text: "Notifications"
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                    color: ThemeService.textBright
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 12
                                    color: ThemeService.background
                                    opacity: 0.46
                                    border.width: 1
                                    border.color: ThemeService.surfaceBright

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 8
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "󰂚"
                                            font.family: ThemeService.iconFont
                                            font.pixelSize: 24
                                            color: ThemeService.primary
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "History"
                                            font.family: ThemeService.fontName
                                            font.pixelSize: 10
                                            color: ThemeService.foreground
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "placeholder"
                                            font.family: ThemeService.fontName
                                            font.pixelSize: 9
                                            color: ThemeService.textDim
                                        }
                                    }
                                }
                            }
                        }

                        StyledRect {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: ThemeService.radiusMedium
                            rectColor: ThemeService.surfaceBright
                            rectOpacity: 0.26
                            borderOpacityValue: 0.1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Text {
                                    text: "Quick"
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                    color: ThemeService.textBright
                                }

                                Repeater {
                                    model: [
                                        { icon: "󰤨", label: "Net" },
                                        { icon: "󰁹", label: "Bat" },
                                        { icon: "󰝟", label: "Audio" },
                                        { icon: "󰐥", label: "Power" }
                                    ]

                                    delegate: Rectangle {
                                        width: parent.width
                                        height: 28
                                        radius: 10
                                        color: ThemeService.background
                                        opacity: 0.56
                                        border.width: 1
                                        border.color: ThemeService.surfaceBright

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 6
                                            Text {
                                                text: modelData.icon
                                                font.family: ThemeService.iconFont
                                                font.pixelSize: 12
                                                color: ThemeService.primary
                                            }
                                            Text {
                                                text: modelData.label
                                                font.family: ThemeService.fontName
                                                font.pixelSize: 9
                                                color: ThemeService.foreground
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
