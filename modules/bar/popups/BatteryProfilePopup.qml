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
    focus: visible

    property var triggerProfile: null
    property int selectedIndex: 0
    property var actionList: [
        { icon: "󰌪", label: "Power Saver", color: ThemeService.secondary, action: "power-saver" },
        { icon: "󰗑", label: "Balanced", color: ThemeService.primary, action: "balanced" },
        { icon: "󰓅", label: "Performance", color: ThemeService.warning, action: "performance" }
    ]

    Text {
        text: "Performance Profiles"
        font.family: ThemeService.fontName
        font.pixelSize: 14
        font.bold: true
        color: ThemeService.primary
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Row {
        spacing: ThemeService.spacingExtraLarge
        anchors.horizontalCenter: parent.horizontalCenter
        
        Repeater {
            model: root.actionList
            delegate: ActionTile {
                id: profileBtn
                required property int index
                required property var modelData

                width: 90; height: 90
                radius: ThemeService.radiusMedium
                icon: modelData.icon
                label: modelData.label
                iconColor: modelData.iconColor || modelData.color
                labelPixelSize: 10
                selected: root.selectedIndex === index
                onClicked: { if (root.triggerProfile) root.triggerProfile(modelData.action); }
                onEntered: root.selectedIndex = index
            }
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            if (root.triggerProfile) root.triggerProfile("close");
            event.accepted = true;
        } else if (event.key === Qt.Key_Right || (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) {
            root.selectedIndex = (root.selectedIndex + 1) % root.actionList.length;
            event.accepted = true;
        } else if (event.key === Qt.Key_Left || (event.key === Qt.Key_Backtab) || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
            root.selectedIndex = (root.selectedIndex - 1 + root.actionList.length) % root.actionList.length;
            event.accepted = true;
        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            if (root.triggerProfile) root.triggerProfile(root.actionList[root.selectedIndex].action);
            event.accepted = true;
        }
    }
}
