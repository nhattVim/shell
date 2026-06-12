import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../config"

PanelWindow {
    id: overlay

    required property var targetScreen
    screen: targetScreen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: ScreenRecorderService.overlayVisible && !ScreenRecorderService.isRecording
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "ei-record"

    onVisibleChanged: selector.reset()

    Connections {
        target: ScreenRecorderService

        function onOverlayRequestSerialChanged() {
            selector.reset();
        }
    }

    mask: Region {
        item: overlay.visible ? fullMask : emptyMask
    }

    Item {
        id: fullMask
        anchors.fill: parent
    }

    Item {
        id: emptyMask
        width: 0
        height: 0
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.35
    }

    Repeater {
        model: ScreenRecorderService.overlayMode === "window" ? ScreenshotService.windows : []

        delegate: Rectangle {
            required property int index
            required property var modelData

            readonly property real screenX: Number(overlay.screen?.x ?? targetScreen.x ?? 0)
            readonly property real screenY: Number(overlay.screen?.y ?? targetScreen.y ?? 0)
            readonly property bool onThisScreen: modelData.x + modelData.width > screenX
                && modelData.x < screenX + overlay.width
                && modelData.y + modelData.height > screenY
                && modelData.y < screenY + overlay.height

            x: modelData.x - screenX
            y: modelData.y - screenY
            width: modelData.width
            height: modelData.height
            z: 5 + index
            visible: onThisScreen
            color: windowMouse.containsMouse ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.22) : "transparent"
            border.color: windowMouse.containsMouse ? ThemeService.primary : Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.55)
            border.width: 2
            radius: 8

            MouseArea {
                id: windowMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ScreenRecorderService.startGeometry(modelData.x, modelData.y, modelData.width, modelData.height)
            }
        }
    }

    Rectangle {
        id: selection
        x: Math.min(selector.startX, selector.currentX)
        y: Math.min(selector.startY, selector.currentY)
        width: Math.abs(selector.currentX - selector.startX)
        height: Math.abs(selector.currentY - selector.startY)
        visible: selector.selecting
        color: Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.18)
        border.color: ThemeService.primary
        border.width: 2
        radius: 6
    }

    FocusScope {
        anchors.fill: parent
        focus: overlay.visible

        Keys.onEscapePressed: ScreenRecorderService.cancelOverlay()
    }

    MouseArea {
        id: selector
        anchors.fill: parent
        cursorShape: ScreenRecorderService.overlayMode === "screen" ? Qt.PointingHandCursor : Qt.CrossCursor
        enabled: overlay.visible && ScreenRecorderService.overlayMode !== "window"
        hoverEnabled: true

        property real startX: 0
        property real startY: 0
        property real currentX: 0
        property real currentY: 0
        property bool selecting: false

        function reset() {
            startX = 0;
            startY = 0;
            currentX = 0;
            currentY = 0;
            selecting = false;
        }

        onPressed: mouse => {
            if (ScreenRecorderService.overlayMode === "screen") {
                ScreenRecorderService.startScreen();
                return;
            }

            startX = mouse.x;
            startY = mouse.y;
            currentX = mouse.x;
            currentY = mouse.y;
            selecting = true;
        }

        onPositionChanged: mouse => {
            if (!selecting) return;
            currentX = Math.max(0, Math.min(width, mouse.x));
            currentY = Math.max(0, Math.min(height, mouse.y));
        }

        onReleased: {
            if (!selecting) return;
            selecting = false;

            const screenX = Number(overlay.screen?.x ?? targetScreen.x ?? 0);
            const screenY = Number(overlay.screen?.y ?? targetScreen.y ?? 0);
            ScreenRecorderService.startGeometry(screenX + Math.round(selection.x), screenY + Math.round(selection.y), Math.round(selection.width), Math.round(selection.height));
            reset();
        }
    }

    Rectangle {
        id: modeBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        width: 286
        height: 56
        radius: 28
        color: Qt.rgba(ThemeService.surface.r, ThemeService.surface.g, ThemeService.surface.b, 0.94)
        border.color: Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.14)
        border.width: 1
        z: 10

        Row {
            anchors.centerIn: parent
            spacing: 8

            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: ScreenRecorderService.recordAudioOutput ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.75) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: ScreenRecorderService.recordAudioOutput ? "󰕾" : "󰝟"
                    font.family: ThemeService.iconFont
                    font.pixelSize: 18
                    color: ScreenRecorderService.recordAudioOutput ? ThemeService.background : ThemeService.foreground
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ScreenRecorderService.toggleAudioOutput()
                }
            }

            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: ScreenRecorderService.recordAudioInput ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.75) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: ScreenRecorderService.recordAudioInput ? "󰍬" : "󰍭"
                    font.family: ThemeService.iconFont
                    font.pixelSize: 18
                    color: ScreenRecorderService.recordAudioInput ? ThemeService.background : ThemeService.foreground
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ScreenRecorderService.toggleAudioInput()
                }
            }

            Rectangle {
                width: 1
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(ThemeService.foreground.r, ThemeService.foreground.g, ThemeService.foreground.b, 0.22)
            }

            Repeater {
                model: [
                    { mode: "region", icon: "󰩭" },
                    { mode: "window", icon: "󰖲" },
                    { mode: "screen", icon: "󰍹" }
                ]

                delegate: Rectangle {
                    required property var modelData

                    width: 40
                    height: 40
                    radius: 20
                    color: ScreenRecorderService.overlayMode === modelData.mode ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.75) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        font.family: ThemeService.iconFont
                        font.pixelSize: 18
                        color: ScreenRecorderService.overlayMode === modelData.mode ? ThemeService.background : ThemeService.foreground
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ScreenRecorderService.setOverlayMode(modelData.mode)
                    }
                }
            }
        }
    }
}
