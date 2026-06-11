import QtQuick
import QtQuick.Layouts
import "../../../services"
import "../../../config"
import "../../../components"

Column {
    id: root
    spacing: ThemeService.spacingLarge
    anchors.fill: parent
    anchors.margins: ThemeService.spacingExtraLarge

    property var triggerPower: null
    property int selectedIndex: 0
    property var actionList: [
        { icon: "󰐥", label: "Shutdown", color: ThemeService.danger, action: "shutdown" },
        { icon: "󰑓", label: "Reboot", color: ThemeService.warning, action: "reboot" },
        { icon: "󰍃", label: "Logout", color: ThemeService.success, action: "logout" }
    ]

    // Text {
    //     text: "System Actions"
    //     font.family: ThemeService.fontName
    //     font.pixelSize: 14
    //     font.bold: true
    //     color: ThemeService.primary
    //     anchors.horizontalCenter: parent.horizontalCenter
    // }

    Row {
        spacing: ThemeService.spacingExtraLarge
        anchors.horizontalCenter: parent.horizontalCenter
        
        Repeater {
            model: root.actionList
            delegate: StyledRect {
                id: powerBtn
                required property int index
                required property var modelData

                width: 80; height: 80
                radius: ThemeService.radiusMedium
                rectColor: ThemeService.surfaceBright
                rectOpacity: (root.selectedIndex === index || powerBtnMouse.containsMouse) ? 0.6 : 0.2
                borderOpacityValue: (root.selectedIndex === index || powerBtnMouse.containsMouse) ? 0.2 : 0.0
                
                Column {
                    anchors.centerIn: parent
                    spacing: ThemeService.spacingSmall
                    Text {
                        text: modelData.icon
                        font.family: ThemeService.iconFont
                        font.pixelSize: 24
                        color: modelData.color
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: modelData.label
                        font.family: ThemeService.fontName
                        font.pixelSize: 9
                        font.bold: true
                        color: ThemeService.textBright
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                MouseArea {
                    id: powerBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (root.triggerPower) root.triggerPower(modelData.action); }
                    onEntered: root.selectedIndex = index
                }
            }
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            if (root.triggerPower) root.triggerPower("close");
            event.accepted = true;
        } else if (event.key === Qt.Key_Right || (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) {
            root.selectedIndex = (root.selectedIndex + 1) % root.actionList.length;
            event.accepted = true;
        } else if (event.key === Qt.Key_Left || (event.key === Qt.Key_Backtab) || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
            root.selectedIndex = (root.selectedIndex - 1 + root.actionList.length) % root.actionList.length;
            event.accepted = true;
        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (root.triggerPower) root.triggerPower(root.actionList[root.selectedIndex].action);
            event.accepted = true;
        }
    }
}
