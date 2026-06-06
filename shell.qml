//@ pragma ShellId nhattVim
import Quickshell
import QtQuick
import Quickshell.Io
import "bar"
import "launcher"
import "services"
import "components"

ShellRoot {
    id: shellRoot

    IpcHandler {
        target: "nhattVim"

        function toggleLauncher(): void {
            LauncherService.buildIndex();
            shellRoot.launcherActive = !shellRoot.launcherActive;
        }

        function nextWallpaper(): void {
            WallpaperService.nextWallpaper();
        }

        function previousWallpaper(): void {
            WallpaperService.previousWallpaper();
        }

        function setWallpaper(path: string): void {
            WallpaperService.setWallpaperByPath(path);
        }

        function setWallpaperIndex(index: int): void {
            WallpaperService.setWallpaperByIndex(index);
        }
    }

    // State managing the visibility of the app launcher
    property bool launcherActive: false

    // Instantiates the Wallpaper background on all connected monitors
    Variants {
        model: Quickshell.screens

        Wallpaper {
            required property var modelData
            screen: modelData
        }
    }

    // Instantiates the floating Bar on all connected monitors
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }

    // Instantiates the Screen Frame on all connected monitors
    Variants {
        model: Quickshell.screens

        ScreenFrame {
            required property var modelData
            targetScreen: modelData
        }
    }

    // Instantiates the app launcher overlay on the primary monitor
    Launcher {
        screen: Quickshell.screens[0]
    }
}
