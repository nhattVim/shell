pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "."

Singleton {
    id: root

    property string activeWindowTitle: ""
    property string activeWindowClass: ""

    // Initial query on startup
    Process {
        id: startupWindow
        command: ["hyprctl", "activewindow", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let obj = JSON.parse(text);
                    root.activeWindowTitle = obj.title || "";
                    root.activeWindowClass = obj.class || "";
                } catch(e) {
                    // No window focused or parsing failed
                }
            }
        }
    }

    // Connect to dynamic socket updates
    Connections {
        target: HyprlandSocket

        function onActiveWindowChanged(clientClass, title) {
            root.activeWindowClass = clientClass || "";
            root.activeWindowTitle = title || "";
        }
    }
}
