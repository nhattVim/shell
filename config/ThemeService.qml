pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // Palette: Sleek dark obsidian theme
    readonly property color background: "#050505"
    readonly property color surface: "#0c0d12"
    readonly property color surfaceBright: "#1e2030"
    
    readonly property color primary: "#bb9af7" // Purple accent
    readonly property color secondary: "#7aa2f7" // Cyan/blue highlight
    readonly property color danger: "#ff5555" // Red for power/alerts
    readonly property color warning: "#ffb86c" // Orange for reboot/performance
    readonly property color success: "#50fa7b" // Green for logout/success
    
    readonly property color foreground: "#a9b1d6" // Light gray text
    readonly property color textDim: "#565f89" // Darker gray for muted text
    readonly property color textBright: "#ffffff" // Pure white for titles/emphasis
    readonly property color scrimColor: "#66000000" // 40% black for overlay/scrim
    
    readonly property color border: "#bb9af7" 
    readonly property real borderOpacity: 0.15
    readonly property real bgOpacity: 0.8
    readonly property real bgOpacityHigh: 0.9
    
    // Geometry
    readonly property int radius: 19
    readonly property int radiusLarge: 24
    readonly property int radiusMedium: 12
    readonly property int radiusSmall: 8
    readonly property int screenRadius: 20 // Dedicated for the 4 corners
    readonly property int animDuration: 250
    readonly property real frameThickness: 0.5

    // Spacings
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 10
    readonly property int spacingLarge: 15
    readonly property int spacingExtraLarge: 20

    // Bar specific
    readonly property int barTotalHeight: 40
    readonly property int barMargin: 10
    readonly property int sideCapsuleHeight: 35
    
    // Dynamic Island specific
    readonly property int islandWidth: 285
    readonly property int islandDashboardWidth: 1052
    readonly property int islandDashboardHeight: 360
    readonly property int islandCompactHeight: 48
    readonly property int islandMenuWidth: 360
    readonly property int islandMenuHeight: 160
    readonly property int islandEarSize: 20
    
    // Launcher specific
    readonly property int launcherWidth: 440
    readonly property int launcherHeight: 383
    readonly property int launcherListHeight: 282
    readonly property int launcherItemHeight: 42
    readonly property int launcherSearchHeight: 40

    // Icon sizes
    readonly property int iconSizeTray: 20
    readonly property int iconSizeLauncher: 18

    // Typography
    readonly property string fontName: "Sans Serif"
    readonly property string iconFont: "Symbols Nerd Font Mono"
}
