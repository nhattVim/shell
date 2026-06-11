//@ pragma ShellId nhattVim
import Quickshell
import QtQuick
import Quickshell.Io
import "bar"
import "launcher"
import "osd"
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

        function volumeUp(): void {
            AudioService.changeVolume(0.05);
        }

        function volumeDown(): void {
            AudioService.changeVolume(-0.05);
        }

        function toggleMute(): void {
            AudioService.toggleMute();
        }

        function brightnessUp(): void {
            BrightnessService.changeBrightness(0.05, null);
        }

        function brightnessDown(): void {
            BrightnessService.changeBrightness(-0.05, null);
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

        Item {
            id: screenBarContainer
            required property var modelData

            BarReservation {
                screen: screenBarContainer.modelData
            }

            Bar {
                screen: screenBarContainer.modelData
            }
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

    // Instantiates the OSD on all connected monitors
    Variants {
        model: Quickshell.screens

        OSD {
            required property var modelData
            targetScreen: modelData
        }
    }

    // Instantiates the app launcher overlay on the primary monitor
    Launcher {
        screen: Quickshell.screens[0]
    }
}
