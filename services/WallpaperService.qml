pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property var wallpaperPaths: []
    property int currentIndex: -1
    property string currentWallpaper: (currentIndex >= 0 && currentIndex < wallpaperPaths.length) ? wallpaperPaths[currentIndex] : ""

    function refresh() {
        if (!scanWallpapers.running) {
            scanWallpapers.running = true;
        }
    }

    // Scans wall dir for files
    Process {
        id: scanWallpapers
        running: false
        
        command: ["find", wallpaperDir, "-maxdepth", "2", "-name", ".*", "-prune", "-o", "-type", "f", "(", "-name", "*.jpg", "-o", "-name", "*.jpeg", "-o", "-name", "*.png", "-o", "-name", "*.webp", ")", "-print"]

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                let lines = text.split("\n");
                let paths = [];
                for (let line of lines) {
                    let cleaned = line.trim();
                    if (cleaned) {
                        paths.push(cleaned);
                    }
                }
                if (paths.length > 0) {
                    paths.sort();
                    root.wallpaperPaths = paths;
                    loadConfig();
                } else {
                    console.log("[WallpaperService] No wallpapers found in", wallpaperDir);
                }
            }
        }
    }

    // Persistent storage for active wallpaper
    FileView {
        id: configFile
        path: Quickshell.env("HOME") + "/.cache/nhattVim/wallpaper.json"
    }
    
    Process {
        id: ensureCacheDir
        command: ["mkdir", "-p", Quickshell.env("HOME") + "/.cache/nhattVim"]
        onExited: {
            scanWallpapers.running = true;
        }
    }

    function loadConfig() {
        try {
            let txt = configFile.text();
            if (txt) {
                let data = JSON.parse(txt);
                if (data && data.currentWallpaper) {
                    let idx = wallpaperPaths.indexOf(data.currentWallpaper);
                    if (idx !== -1) {
                        currentIndex = idx;
                        return;
                    }
                }
            }
        } catch(e) {
            console.log("[WallpaperService] Config file not found or invalid. Loading defaults.");
        }
        
        // Fallback to first wallpaper in directory
        if (wallpaperPaths.length > 0) {
            currentIndex = 0;
        }
    }

    function saveConfig() {
        if (!currentWallpaper) return;
        let data = {
            "currentWallpaper": currentWallpaper
        };
        configFile.setText(JSON.stringify(data, null, 2));
    }

    function nextWallpaper() {
        if (wallpaperPaths.length === 0) return;
        currentIndex = (currentIndex + 1) % wallpaperPaths.length;
        saveConfig();
    }

    function previousWallpaper() {
        if (wallpaperPaths.length === 0) return;
        currentIndex = (currentIndex - 1 + wallpaperPaths.length) % wallpaperPaths.length;
        saveConfig();
    }

    // Allow setting via global methods
    function setWallpaperByIndex(idx) {
        if (idx >= 0 && idx < wallpaperPaths.length) {
            currentIndex = idx;
            saveConfig();
        }
    }
    
    function setWallpaperByPath(path) {
        let idx = wallpaperPaths.indexOf(path);
        if (idx !== -1) {
            currentIndex = idx;
            saveConfig();
        }
    }

    Component.onCompleted: {
        ensureCacheDir.running = true;
    }
}
