import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.volume

RowLayout {
    id: root

    property var target: null
    property int value: target ? Math.round((target.volume / PulseAudio.NormalVolume) * 100.0) : 0
    property bool muted: target ? target.muted : false
    property bool hasVolume: target ? (target.hasVolume !== undefined ? target.hasVolume : true) : false
    property bool corked: target ? (target.corked !== undefined ? target.corked : false) : false
    property int labelWidth: 38

    signal moved(int val)
    signal muteToggled()

    spacing: PlasmaCore.Units.smallSpacing

    PlasmaComponents3.Slider {
        id: slider
        Layout.fillWidth: true
        from: 0
        to: 100
        stepSize: 1
        value: root.value
        enabled: root.hasVolume && (root.target ? root.target.volumeWritable : true)

        onMoved: {
            const intVal = Math.round(slider.value)
            root.moved(intVal)
            if (root.target && root.target.volumeWritable) {
                root.target.volume = Math.round((intVal / 100.0) * PulseAudio.NormalVolume)
                if (intVal === 0) {
                    root.target.muted = true
                } else if (root.target.muted) {
                    root.target.muted = false
                }
            }
        }

        onPressedChanged: {
            if (!pressed) {
                value = Qt.binding(function() {
                    if (!root.target) return 0
                    return Math.round((root.target.volume / PulseAudio.NormalVolume) * 100.0)
                })
            }
        }
    }

    PlasmaComponents3.Label {
        Layout.preferredWidth: root.labelWidth
        horizontalAlignment: Text.AlignRight
        text: root.value + "%"
        font.pixelSize: PlasmaCore.Units.fontPixelSize * 0.9
        opacity: root.muted || root.corked || !root.target ? 0.5 : 0.85
    }

    PlasmaComponents3.ToolButton {
        icon.name: root.muted ? "audio-volume-muted" : "audio-volume-high"
        enabled: root.hasVolume && !!root.target
        onClicked: {
            root.muteToggled()
            if (root.target) {
                root.target.muted = !root.target.muted
            }
        }
    }
}
