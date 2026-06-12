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

    visible: ScreenshotService.regionOverlayVisible && !ScreenshotService.busy
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "ei-screenshot"

    onVisibleChanged: selector.reset()

    Connections {
        target: ScreenshotService

        function onRegionRequestSerialChanged() {
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
        model: ScreenshotService.overlayMode === "window" ? ScreenshotService.windows : []

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
            border.color: windowMouse.containsMouse ? ThemeService.primary : Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.5)
            border.width: 2
            radius: 8

            Text {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: 8
                width: parent.width - 16
                text: modelData.app || modelData.title || "Window"
                font.family: ThemeService.fontName
                font.pixelSize: 12
                font.weight: Font.Bold
                color: ThemeService.textBright
                elide: Text.ElideRight
                visible: parent.width > 90 && parent.height > 48
            }

            MouseArea {
                id: windowMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ScreenshotService.captureGeometry(modelData.x, modelData.y, modelData.width, modelData.height)
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

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 88
        text: ScreenshotService.overlayMode === "region" ? "Drag to capture, Esc to cancel"
            : ScreenshotService.overlayMode === "window" ? "Select a window, Esc to cancel"
            : "Click to capture this screen, Esc to cancel"
        font.family: ThemeService.fontName
        font.pixelSize: 13
        color: ThemeService.textBright
        opacity: selector.selecting ? 0 : 0.9
    }

    FocusScope {
        anchors.fill: parent
        focus: overlay.visible

        Keys.onEscapePressed: ScreenshotService.cancelRegion()
    }

    MouseArea {
        id: selector
        anchors.fill: parent
        cursorShape: ScreenshotService.overlayMode === "screen" ? Qt.PointingHandCursor : Qt.CrossCursor
        enabled: overlay.visible && ScreenshotService.overlayMode !== "window"
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
            if (ScreenshotService.overlayMode === "screen") {
                const screenX = Number(overlay.screen?.x ?? targetScreen.x ?? 0);
                const screenY = Number(overlay.screen?.y ?? targetScreen.y ?? 0);
                ScreenshotService.captureGeometry(screenX, screenY, overlay.width, overlay.height);
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

            const localX = Math.round(selection.x);
            const localY = Math.round(selection.y);
            const localW = Math.round(selection.width);
            const localH = Math.round(selection.height);

            const screenX = Number(overlay.screen?.x ?? targetScreen.x ?? 0);
            const screenY = Number(overlay.screen?.y ?? targetScreen.y ?? 0);
            ScreenshotService.captureGeometry(screenX + localX, screenY + localY, localW, localH);
            reset();
        }
    }

    Rectangle {
        id: modeBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        width: 196
        height: 56
        radius: 28
        color: Qt.rgba(ThemeService.surface.r, ThemeService.surface.g, ThemeService.surface.b, 0.92)
        border.color: Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.14)
        border.width: 1
        z: 10

        Row {
            anchors.centerIn: parent
            spacing: 10

            Repeater {
                model: [
                    { mode: "region", icon: "󰩭" },
                    { mode: "window", icon: "󰖲" },
                    { mode: "screen", icon: "󰍹" }
                ]

                delegate: Rectangle {
                    required property var modelData

                    width: 44
                    height: 44
                    radius: 22
                    color: ScreenshotService.overlayMode === modelData.mode ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.75) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        font.family: ThemeService.iconFont
                        font.pixelSize: 19
                        color: ScreenshotService.overlayMode === modelData.mode ? ThemeService.background : ThemeService.foreground
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ScreenshotService.setOverlayMode(modelData.mode)
                    }
                }
            }
        }
    }
}
