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

    WindowTargetOverlay {
        anchors.fill: parent
        windows: ScreenshotService.overlayMode === "window" ? ScreenshotService.windows : []
        screenX: Number(overlay.screen?.x ?? targetScreen.x ?? 0)
        screenY: Number(overlay.screen?.y ?? targetScreen.y ?? 0)
        inactiveBorderOpacity: 0.5
        showTitle: true
        onSelected: windowData => ScreenshotService.captureGeometry(windowData.x, windowData.y, windowData.width, windowData.height)
    }

    SelectionRect {
        id: selection
        selector: selector
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

    DragSelector {
        id: selector
        anchors.fill: parent
        screenMode: ScreenshotService.overlayMode === "screen"
        enabled: overlay.visible && ScreenshotService.overlayMode !== "window"

        onScreenClicked: {
            const screenX = Number(overlay.screen?.x ?? targetScreen.x ?? 0);
            const screenY = Number(overlay.screen?.y ?? targetScreen.y ?? 0);
            ScreenshotService.captureGeometry(screenX, screenY, overlay.width, overlay.height);
        }

        onRegionSelected: (localX, localY, localW, localH) => {
            const screenX = Number(overlay.screen?.x ?? targetScreen.x ?? 0);
            const screenY = Number(overlay.screen?.y ?? targetScreen.y ?? 0);
            ScreenshotService.captureGeometry(screenX + localX, screenY + localY, localW, localH);
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

                delegate: ToolModeButton {
                    required property var modelData

                    width: 44
                    height: 44
                    icon: modelData.icon
                    iconPixelSize: 19
                    active: ScreenshotService.overlayMode === modelData.mode
                    onClicked: ScreenshotService.setOverlayMode(modelData.mode)
                }
            }
        }
    }
}
