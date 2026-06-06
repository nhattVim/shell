pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property bool ready: Pipewire.defaultAudioSink?.ready ?? false
    readonly property real volume: ready ? Pipewire.defaultAudioSink.audio.volume : 0
    readonly property bool muted: ready ? Pipewire.defaultAudioSink.audio.muted : false

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    function setVolume(val) {
        if (ready && Pipewire.defaultAudioSink.audio) {
            Pipewire.defaultAudioSink.audio.volume = Math.max(0.0, Math.min(1.0, val));
        }
    }

    function changeVolume(delta) {
        if (ready && Pipewire.defaultAudioSink.audio) {
            let current = Pipewire.defaultAudioSink.audio.volume;
            setVolume(current + delta);
        }
    }

    function toggleMute() {
        if (ready && Pipewire.defaultAudioSink.audio) {
            Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
        }
    }
}
