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
    
    readonly property color foreground: "#a9b1d6" // Light gray text
    readonly property color textDim: "#565f89" // Darker gray for muted text
    
    readonly property color border: "#bb9af7" 
    readonly property real borderOpacity: 0.15
    readonly property real bgOpacity: 0.8
    readonly property real bgOpacityHigh: 0.9
    
    // Geometry
    readonly property int radius: 19
    readonly property int radiusSmall: 6
    readonly property int animDuration: 250
    readonly property real frameThickness: 1.0

    // Bar specific
    readonly property int barHeight: 38
    readonly property int islandWidth: 380 // Length kept as requested
    readonly property int islandDashboardWidth: 540
    readonly property int islandDashboardHeight: 280
    
    // Icon sizes
    readonly property int iconSizeTray: 20
    readonly property int iconSizeLauncher: 18

    // Typography
    readonly property string fontName: "Sans Serif"
}
