pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string pendingAction: ""

    function commandForPowerAction(action) {
        if (action === "shutdown") return ["systemctl", "poweroff"];
        if (action === "reboot") return ["reboot"];
        if (action === "logout") return ["hyprctl", "dispatch", "exit"];
        return [];
    }

    function runPowerAction(action) {
        if (actionProcess.running) return false;

        const command = commandForPowerAction(action);
        if (command.length === 0) return false;

        pendingAction = action;
        actionProcess.command = command;
        actionProcess.running = true;
        return true;
    }

    Process {
        id: actionProcess
        running: false
        onExited: root.pendingAction = ""
    }
}
