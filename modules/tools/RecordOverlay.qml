import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services"
import "../../config"
import "../../components"

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

    WindowTargetOverlay {
        anchors.fill: parent
        windows: ScreenRecorderService.overlayMode === "window" ? ScreenshotService.windows : []
        screenX: Number(overlay.screen?.x ?? targetScreen.x ?? 0)
        screenY: Number(overlay.screen?.y ?? targetScreen.y ?? 0)
        inactiveBorderOpacity: 0.55
        showTitle: false
        onSelected: windowData => ScreenRecorderService.startGeometry(windowData.x, windowData.y, windowData.width, windowData.height)
    }

    SelectionRect {
        id: selection
        selector: selector
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

            ToolModeButton {
                width: 40
                height: 40
                icon: ScreenRecorderService.recordAudioOutput ? "󰕾" : "󰝟"
                active: ScreenRecorderService.recordAudioOutput
                onClicked: ScreenRecorderService.toggleAudioOutput()
            }

            ToolModeButton {
                width: 40
                height: 40
                icon: ScreenRecorderService.recordAudioInput ? "󰍬" : "󰍭"
                active: ScreenRecorderService.recordAudioInput
                onClicked: ScreenRecorderService.toggleAudioInput()
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

                delegate: ToolModeButton {
                    required property var modelData

                    width: 40
                    height: 40
                    icon: modelData.icon
                    active: ScreenRecorderService.overlayMode === modelData.mode
                    onClicked: ScreenRecorderService.setOverlayMode(modelData.mode)
                }
            }
        }
    }
}
