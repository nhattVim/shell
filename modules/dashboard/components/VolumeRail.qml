import QtQuick
import QtQuick.Layouts
import "../../../services"
import "../../../config"

Item {
    id: root

    Rectangle {
        anchors.fill: parent
        radius: 28
        color: ThemeService.background
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 7
        spacing: 6

        Item {
            id: brightnessSlider

            Layout.fillWidth: true
            Layout.fillHeight: true

            readonly property real value: BrightnessService.ready ? BrightnessService.value : 0
            readonly property real trackTop: 10
            readonly property real trackBottom: brightnessButton.y - 8
            readonly property real trackHeight: Math.max(1, trackBottom - trackTop)

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: brightnessSlider.trackTop
                width: 4
                height: brightnessSlider.trackHeight
                radius: 2
                color: ThemeService.surfaceBright
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: brightnessSlider.trackTop + brightnessSlider.trackHeight * (1 - brightnessSlider.value)
                width: 4
                height: brightnessSlider.trackHeight * brightnessSlider.value
                radius: 2
                color: ThemeService.primary
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: brightnessSlider.trackTop + brightnessSlider.trackHeight * (1 - brightnessSlider.value) - height / 2
                width: 16
                height: 5
                radius: 2
                color: ThemeService.textBright
            }

            MouseArea {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: brightnessButton.top
                }
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse => updateBrightness(mouse.y)
                onPositionChanged: mouse => {
                    if (pressed) updateBrightness(mouse.y);
                }
                onWheel: wheel => {
                    BrightnessService.changeBrightness(wheel.angleDelta.y > 0 ? 0.04 : -0.04, null);
                    wheel.accepted = true;
                }
            }

            RailButton {
                id: brightnessButton
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                width: 48
                height: 48
                icon: "󰃠"
                selected: false
                stableSize: true
                stableButtonSize: 40
                iconPixelSize: 16
                accent: ThemeService.primary
            }
        }

        Item {
            id: volumeSlider

            Layout.fillWidth: true
            Layout.fillHeight: true

            readonly property real value: AudioService.ready ? AudioService.volume : 0
            readonly property real trackTop: 10
            readonly property real trackBottom: speakerButton.y - 8
            readonly property real trackHeight: Math.max(1, trackBottom - trackTop)

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: volumeSlider.trackTop
                width: 4
                height: volumeSlider.trackHeight
                radius: 2
                color: ThemeService.surfaceBright
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: volumeSlider.trackTop + volumeSlider.trackHeight * (1 - volumeSlider.value)
                width: 4
                height: volumeSlider.trackHeight * volumeSlider.value
                radius: 2
                color: ThemeService.primary
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: volumeSlider.trackTop + volumeSlider.trackHeight * (1 - volumeSlider.value) - height / 2
                width: 16
                height: 5
                radius: 2
                color: ThemeService.textBright
            }

            MouseArea {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: speakerButton.top
                }
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse => updateVolume(mouse.y)
                onPositionChanged: mouse => {
                    if (pressed) updateVolume(mouse.y);
                }
                onWheel: wheel => {
                    AudioService.changeVolume(wheel.angleDelta.y > 0 ? 0.04 : -0.04);
                    wheel.accepted = true;
                }
            }

            RailButton {
                id: speakerButton
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                width: 48
                height: 48
                icon: AudioService.muted ? "󰝟" : "󰕾"
                selected: !AudioService.muted
                stableSize: true
                stableButtonSize: 40
                iconPixelSize: 15
                accent: ThemeService.primary

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: AudioService.toggleMute()
                }
            }
        }

        Item {
            id: micSlider

            Layout.fillWidth: true
            Layout.fillHeight: true

            readonly property real value: AudioService.micReady ? AudioService.micVolume : 0
            readonly property real trackTop: 10
            readonly property real trackBottom: micButton.y - 8
            readonly property real trackHeight: Math.max(1, trackBottom - trackTop)

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: micSlider.trackTop
                width: 4
                height: micSlider.trackHeight
                radius: 2
                color: ThemeService.surfaceBright
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: micSlider.trackTop + micSlider.trackHeight * (1 - micSlider.value)
                width: 4
                height: micSlider.trackHeight * micSlider.value
                radius: 2
                color: ThemeService.primary
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: micSlider.trackTop + micSlider.trackHeight * (1 - micSlider.value) - height / 2
                width: 16
                height: 5
                radius: 2
                color: ThemeService.textBright
            }

            MouseArea {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: micButton.top
                }
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse => updateMic(mouse.y)
                onPositionChanged: mouse => {
                    if (pressed) updateMic(mouse.y);
                }
                onWheel: wheel => {
                    AudioService.changeMicVolume(wheel.angleDelta.y > 0 ? 0.04 : -0.04);
                    wheel.accepted = true;
                }
            }

            RailButton {
                id: micButton
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                width: 48
                height: 48
                icon: AudioService.micMuted ? "󰍭" : "󰍬"
                selected: !AudioService.micMuted
                stableSize: true
                stableButtonSize: 40
                iconPixelSize: 16
                accent: ThemeService.primary

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: AudioService.toggleMicMute()
                }
            }
        }
    }

    function sliderValue(yPos, slider) {
        const localY = Math.max(0, Math.min(slider.trackHeight, yPos - slider.trackTop));
        return 1 - localY / slider.trackHeight;
    }

    function updateBrightness(yPos) {
        if (BrightnessService.ready) {
            BrightnessService.setBrightness(sliderValue(yPos, brightnessSlider), null);
        }
    }

    function updateVolume(yPos) {
        if (AudioService.ready) {
            AudioService.setVolume(sliderValue(yPos, volumeSlider));
        }
    }

    function updateMic(yPos) {
        if (AudioService.micReady) {
            AudioService.setMicVolume(sliderValue(yPos, micSlider));
        }
    }
}
