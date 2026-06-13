import QtQuick
import Quickshell
import Quickshell.Io
import "../../services"

Item {
    id: root

    required property var shellRoot

    IpcHandler {
        target: "ei"

        function launcher(): void {
            LauncherService.buildIndex();
            root.shellRoot.launcherActive = !root.shellRoot.launcherActive;
        }

        function clipboard(): void {
            ClipboardService.refresh();
            root.shellRoot.clipboardActive = !root.shellRoot.clipboardActive;
        }

        function wallpaper(): void {
            WallpaperService.refresh();
            root.shellRoot.wallpaperPickerActive = !root.shellRoot.wallpaperPickerActive;
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

        function micMute(): void {
            AudioService.toggleMute();
        }

        function brightnessUp(): void {
            BrightnessService.changeBrightness(0.05, null);
        }

        function brightnessDown(): void {
            BrightnessService.changeBrightness(-0.05, null);
        }

        function screenshot(): void {
            ScreenshotService.captureRegion();
        }

        function screenshotScreen(): void {
            ScreenshotService.captureScreen();
        }

        function screenrecord(): void {
            ScreenRecorderService.toggle();
        }

        function lock(): void {
            LockscreenService.lock();
        }
    }
}
