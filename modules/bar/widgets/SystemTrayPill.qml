import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Wayland
import "../../../services"
import "../../../config"
import "../../../components"

StyledRect {
    id: root

    property int pillHeight: ThemeService.sideCapsuleHeight
    property int closePopupsToken: 0

    signal popupOpened()

    height: pillHeight
    width: trayRow.implicitWidth + ThemeService.islandEarSize
    radius: height / 2
    visible: trayRow.count > 0
    rectColor: ThemeService.background
    rectOpacity: ThemeService.bgOpacity
    borderOpacityValue: 0.0

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: ThemeService.spacingSmall
        property int count: trayRepeater.count

        Repeater {
            id: trayRepeater
            model: SystemTray.items

            Item {
                id: trayDelegate
                required property var modelData
                width: ThemeService.iconSizeTray
                height: width

                IconImage {
                    anchors.fill: parent
                    source: {
                        const icon = trayDelegate.modelData.icon ? trayDelegate.modelData.icon.toString() : "";
                        if (icon.length === 0) return Quickshell.iconPath("image-missing");
                        if (icon.includes("/") || icon.includes(".")) return trayDelegate.modelData.icon;
                        return Quickshell.iconPath(icon, "image-missing");
                    }
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: event => {
                        if (event.button === Qt.LeftButton) {
                            trayDelegate.modelData.activate();
                        } else if (event.button === Qt.RightButton && trayDelegate.modelData.hasMenu) {
                            trayPopup.toggle();
                        }
                        event.accepted = true;
                    }
                }

                PopupWindow {
                    id: trayPopup

                    property int popupWidth: 240
                    property int popupMaxHeight: 420
                    property int popupPadding: 8
                    property real popupOpacity: 0
                    property real popupScale: 0.94

                    anchor.item: trayDelegate
                    anchor.rect.x: trayDelegate.width - implicitWidth
                    anchor.rect.y: trayDelegate.height + ThemeService.spacingMedium
                    anchor.rect.width: 0
                    anchor.rect.height: 0

                    implicitWidth: popupWidth
                    implicitHeight: Math.min(menuColumn.implicitHeight + popupPadding * 2, popupMaxHeight)
                    color: "transparent"
                    grabFocus: true
                    visible: false

                    QsMenuOpener {
                        id: menuOpener
                        menu: trayDelegate.modelData.menu
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: ThemeService.radiusMedium
                        color: Qt.rgba(ThemeService.background.r, ThemeService.background.g, ThemeService.background.b, ThemeService.bgOpacityHigh)
                        border.width: 1
                        border.color: Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, ThemeService.borderOpacity)
                        opacity: trayPopup.popupOpacity
                        scale: trayPopup.popupScale
                        transformOrigin: Item.TopRight

                        Behavior on opacity { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutCubic } }
                        Behavior on scale { NumberAnimation { duration: ThemeService.animDuration; easing.type: Easing.OutCubic } }

                        Flickable {
                            anchors.fill: parent
                            anchors.margins: trayPopup.popupPadding
                            contentWidth: width
                            contentHeight: menuColumn.implicitHeight
                            clip: true

                            Column {
                                id: menuColumn
                                width: parent.width
                                spacing: 2

                                Repeater {
                                    model: menuOpener.children ? menuOpener.children.values : []

                                    Column {
                                        required property var modelData
                                        width: menuColumn.width
                                        spacing: 2
                                        property bool submenuExpanded: false

                                        TrayMenuItem {
                                            width: parent.width
                                            textStr: modelData.text || ""
                                            iconSource: modelData.icon || ""
                                            isSeparator: modelData.isSeparator || false
                                            hasSubmenu: modelData.hasChildren || false
                                            expanded: parent.submenuExpanded
                                            buttonType: modelData.buttonType || 0
                                            checkState: modelData.checkState || 0

                                            onClicked: {
                                                if (modelData.hasChildren) {
                                                    parent.submenuExpanded = !parent.submenuExpanded;
                                                } else {
                                                    if (modelData.triggered) modelData.triggered();
                                                    else if (modelData.activate) modelData.activate();
                                                    trayPopup.close();
                                                }
                                            }
                                        }

                                        Column {
                                            visible: parent.submenuExpanded && modelData.hasChildren
                                            width: parent.width
                                            spacing: 2

                                            QsMenuOpener {
                                                id: subMenuOpener
                                                menu: modelData.hasChildren ? modelData : null
                                            }

                                            Repeater {
                                                model: subMenuOpener.children ? subMenuOpener.children.values : []

                                                TrayMenuItem {
                                                    required property var modelData
                                                    width: parent.width
                                                    depth: 1
                                                    textStr: modelData.text || ""
                                                    iconSource: modelData.icon || ""
                                                    isSeparator: modelData.isSeparator || false
                                                    buttonType: modelData.buttonType || 0
                                                    checkState: modelData.checkState || 0

                                                    onClicked: {
                                                        if (modelData.triggered) modelData.triggered();
                                                        else if (modelData.activate) modelData.activate();
                                                        trayPopup.close();
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Timer {
                        id: closeTimer
                        interval: ThemeService.animDuration + 50
                        onTriggered: trayPopup.visible = false
                    }

                    function open() {
                        if (visible) return;
                        root.popupOpened();
                        popupOpacity = 0;
                        popupScale = 0.94;
                        visible = true;
                        Qt.callLater(() => {
                            popupOpacity = 1;
                            popupScale = 1;
                        });
                    }

                    function close() {
                        if (!visible) return;
                        popupOpacity = 0;
                        popupScale = 0.94;
                        closeTimer.restart();
                    }

                    function toggle() {
                        if (visible) close();
                        else open();
                    }
                }

                Connections {
                    target: root
                    function onClosePopupsTokenChanged() {
                        trayPopup.close();
                    }
                }
            }
        }
    }
}
