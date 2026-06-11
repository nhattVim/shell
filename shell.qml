//@ pragma ShellId nhattVim
import Quickshell
import QtQuick
import "modules/shell"
import "modules/launcher"
import "modules/osd"
import "modules/frame"
import "modules/wallpaper"
import "services"

ShellRoot {
    id: shellRoot

    ShellIpc {
        shellRoot: shellRoot
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

    // Instantiates the app launcher overlay on the primary monitor
    Launcher {
        screen: Quickshell.screens[0]
    }
}
