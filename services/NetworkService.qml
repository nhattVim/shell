pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool wifiConnected: false
    property bool wifiEnabled: true
    property string wifiName: ""
    property int wifiSignal: 0
    property bool scanning: false
    property var wifiNetworks: []

    readonly property string wifiIcon: {
        if (!wifiConnected) return "󰤮";
        if (wifiSignal >= 75) return "󰤨";
        if (wifiSignal >= 50) return "󰤥";
        if (wifiSignal >= 25) return "󰤢";
        return "󰤟";
    }

    function refresh() {
        if (!wifiProcess.running) {
            wifiProcess.running = true;
        }
        if (!wifiRadioProcess.running) {
            wifiRadioProcess.running = true;
        }
    }

    function rescan() {
        if (!wifiEnabled) {
            root.refresh();
            return;
        }
        if (!scanProcess.running) {
            scanning = true;
            scanProcess.running = true;
        }
    }

    function setWifiEnabled(enabled) {
        if (wifiToggleProcess.running) return;
        wifiToggleProcess.command = ["nmcli", "radio", "wifi", enabled ? "on" : "off"];
        wifiToggleProcess.running = true;
    }

    function connectToNetwork(network) {
        if (!network || !network.ssid || connectProcess.running) return;
        connectProcess.command = ["nmcli", "dev", "wifi", "connect", network.ssid];
        connectProcess.running = true;
    }

    function splitNmcliLine(line) {
        let parts = [];
        let current = "";

        for (let i = 0; i < line.length; i++) {
            let ch = line[i];
            if (ch === "\\") {
                if (i + 1 < line.length) {
                    current += line[i + 1];
                    i++;
                }
            } else if (ch === ":") {
                parts.push(current);
                current = "";
            } else {
                current += ch;
            }
        }

        parts.push(current);
        return parts;
    }

    function parseWifiList(text) {
        let connected = false;
        let name = "";
        let signal = 0;
        let networks = [];
        let seen = {};
        let lines = text.trim().length > 0 ? text.trim().split("\n") : [];

        for (let i = 0; i < lines.length; i++) {
            let parts = splitNmcliLine(lines[i]);
            if (parts.length < 4) continue;

            let active = parts[0] === "yes";
            let strength = parseInt(parts[1]) || 0;
            let security = parts[2] || "";
            let ssid = parts.slice(3).join(":");
            if (ssid === "") continue;

            if (!seen[ssid] || strength > seen[ssid].signal) {
                seen[ssid] = {
                    active: active,
                    ssid: ssid,
                    signal: strength,
                    security: security,
                    secured: security !== ""
                };
            }

            if (active) {
                connected = true;
                name = ssid;
                signal = strength;
            }
        }

        for (let key in seen) networks.push(seen[key]);
        networks.sort((a, b) => {
            if (a.active !== b.active) return a.active ? -1 : 1;
            return b.signal - a.signal;
        });

        root.wifiConnected = connected;
        root.wifiName = name;
        root.wifiSignal = signal;
        root.wifiNetworks = networks;
    }

    Process {
        id: wifiProcess
        command: ["nmcli", "-t", "-f", "ACTIVE,SIGNAL,SECURITY,SSID", "dev", "wifi"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseWifiList(text);
            }
        }
    }

    Process {
        id: wifiRadioProcess
        command: ["nmcli", "radio", "wifi"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.wifiEnabled = text.trim() === "enabled"
        }
    }

    Process {
        id: scanProcess
        command: ["nmcli", "-t", "-f", "ACTIVE,SIGNAL,SECURITY,SSID", "dev", "wifi", "list", "--rescan", "yes"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.scanning = false;
                root.parseWifiList(text);
            }
        }
    }

    Process {
        id: connectProcess
        running: false
        onExited: root.refresh()
    }

    Process {
        id: wifiToggleProcess
        running: false
        onExited: root.refresh()
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
