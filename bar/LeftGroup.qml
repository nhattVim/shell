import QtQuick
import Quickshell
import "../services"
import "../components"

Row {
    id: root
    spacing: 6

    // Launcher Pill
    StyledRect {
        id: launcherPill
        height: ThemeService.barHeight
        width: height
        radius: height / 2
        rectColor: ThemeService.background
        rectOpacity: ThemeService.bgOpacity
        borderOpacityValue: 0.0

        Image {
            anchors.centerIn: parent
            width: ThemeService.iconSizeLauncher
            height: width
            source: "file:///home/albedo/.config/quickshell/ambxst-lite/assets/ambxst/ambxst-icon.svg"
            smooth: true
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                LauncherService.buildIndex();
                shellRoot.launcherActive = !shellRoot.launcherActive;
            }
            onEntered: launcherPill.rectOpacity = 1.0
            onExited: launcherPill.rectOpacity = ThemeService.bgOpacity
        }
    }

    // Workspaces Pill
    StyledRect {
        id: workspacesPill
        height: ThemeService.barHeight
        width: wsRow.implicitWidth + 24
        radius: height / 2
        rectColor: ThemeService.background
        rectOpacity: ThemeService.bgOpacity
        borderOpacityValue: 0.0

        Row {
            id: wsRow
            anchors.centerIn: parent
            spacing: 8
            Repeater {
                model: 10
                Rectangle {
                    required property int index
                    readonly property bool isActive: WorkspaceService.activeWorkspaceId === (index + 1)
                    width: isActive ? 16 : 6
                    height: 6
                    radius: 3
                    color: isActive ? ThemeService.primary : ThemeService.textDim
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuint } }
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onWheel: event => {
                let delta = event.angleDelta.y > 0 ? -1 : 1;
                let p = Qt.createQmlObject('import Quickshell.Io; Process { }', root);
                p.command = ["hyprctl", "dispatch", "workspace", (delta > 0 ? "e+1" : "e-1")];
                p.onExited.connect(() => p.destroy());
                p.running = true;
            }
        }
    }
}
