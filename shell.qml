//@ pragma ShellId ei
import Quickshell
import QtQuick
import "modules/shell"
import "modules/launcher"
import "modules/clipboard"
import "modules/osd"
import "modules/frame"
import "modules/wallpaper"
import "modules/notifications"
import "modules/tools"
import "services"

ShellRoot {
    id: shellRoot

    readonly property bool idleServiceLoaded: IdleService.enabled
    readonly property bool wallpaperThemeLoaded: WallpaperThemeService.enabled

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

            ReservationWindow {
                screen: screenBarContainer.modelData
            }

            ShellPanel {
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

    // Instantiates screenshot region overlays on all connected monitors
    Variants {
        model: Quickshell.screens

        ScreenshotOverlay {
            required property var modelData
            targetScreen: modelData
        }
    }

    // Instantiates screen recording overlays on all connected monitors
    Variants {
        model: Quickshell.screens

        RecordOverlay {
            required property var modelData
            targetScreen: modelData
        }
    }

    // Shows recording controls on the primary monitor while recording
    RecordIndicator {
        targetScreen: Quickshell.screens[0]
    }

    // Instantiates floating notification popups on the primary monitor
    NotificationPopup {
        targetScreen: Quickshell.screens[0]
    }

    // Instantiates the app launcher overlay on the primary monitor
    Launcher {
        screen: Quickshell.screens[0]
    }

    // Instantiates the clipboard history overlay on the primary monitor
    Clipboard {
        screen: Quickshell.screens[0]
    }

    // Instantiates the wallpaper picker overlay on the primary monitor
    WallpaperPicker {
        screen: Quickshell.screens[0]
    }

}
