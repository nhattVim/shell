pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "."

Singleton {
    id: root

    property var workspaces: []
    property int activeWorkspaceId: 1
    property string activeWorkspaceName: "1"

    // Queries initial list on startup
    Process {
        id: startupWorkspaces
        command: ["hyprctl", "workspaces", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let list = JSON.parse(text);
                    let arr = [];
                    for (let i = 0; i < list.length; i++) {
                        // Avoid special workspaces showing in the main list if not desired,
                        // or keep them. Let's filter out negative ids (special workspace is usually -99)
                        if (list[i].id > 0) {
                            arr.push({
                                id: list[i].id,
                                name: list[i].name
                            });
                        }
                    }
                    arr.sort((a, b) => a.id - b.id);
                    root.workspaces = arr;
                } catch(e) {
                    console.log("WorkspaceService: Error parsing initial workspaces:", e);
                }
            }
        }
    }

    // Queries active workspace on startup
    Process {
        id: startupActiveWorkspace
        command: ["hyprctl", "activeworkspace", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let obj = JSON.parse(text);
                    root.activeWorkspaceId = obj.id;
                    root.activeWorkspaceName = obj.name;
                } catch(e) {
                    // Fallback: Query monitors
                    startupMonitors.running = true;
                }
            }
        }
    }

    Process {
        id: startupMonitors
        command: ["hyprctl", "monitors", "-j"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let list = JSON.parse(text);
                    let active = list.find(m => m.focused);
                    if (active && active.activeWorkspace) {
                        root.activeWorkspaceId = active.activeWorkspace.id;
                        root.activeWorkspaceName = active.activeWorkspace.name;
                    }
                } catch(e) {}
            }
        }
    }

    // Connect to dynamic socket updates
    Connections {
        target: HyprlandSocket

        function onWorkspaceChanged(id, name) {
            if (id > 0) {
                root.activeWorkspaceId = id;
                root.activeWorkspaceName = name;
                
                // Ensure the active workspace is in the list
                let exists = root.workspaces.some(w => w.id === id);
                if (!exists) {
                    let arr = Array.from(root.workspaces);
                    arr.push({ id: id, name: name });
                    arr.sort((a, b) => a.id - b.id);
                    root.workspaces = arr;
                }
            }
        }

        function onWorkspaceCreated(id, name) {
            if (id > 0) {
                let exists = root.workspaces.some(w => w.id === id);
                if (!exists) {
                    let arr = Array.from(root.workspaces);
                    arr.push({ id: id, name: name });
                    arr.sort((a, b) => a.id - b.id);
                    root.workspaces = arr;
                }
            }
        }

        function onWorkspaceDestroyed(id, name) {
            if (id > 0) {
                let arr = root.workspaces.filter(w => w.id !== id);
                root.workspaces = arr;
            }
        }
    }
}
