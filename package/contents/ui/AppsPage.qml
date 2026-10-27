import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.private.volume
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: root

    readonly property SinkInputModel sinkInputModel: SinkInputModel {}
    readonly property SinkModel rawSinkModel: SinkModel {}

    readonly property PulseObjectFilterModel hwSinkModel: PulseObjectFilterModel {
        sourceModel: root.rawSinkModel
        filterVirtualDevices: true
    }

    readonly property string targetHardwareSinkName: "alsa_output.pci-0000_10_00.6.analog-stereo"

    property var masterSink: null

    function findMaster() {
        // 1) Cerca il sink hardware Ryzen esatto
        for (let i = 0; i < rawSinkModel.count; i++) {
            const idx = rawSinkModel.index(i, 0)
            const obj = rawSinkModel.data(idx, rawSinkModel.role("PulseObject"))
            if (obj && obj.name === targetHardwareSinkName) {
                if (masterSink !== obj) {
                    masterSink = obj
                }
                return true
            }
        }
        // 2) Primo sink non virtuale
        if (hwSinkModel.count > 0) {
            const idx = hwSinkModel.index(0, 0)
            const obj = hwSinkModel.data(idx, hwSinkModel.role("PulseObject"))
            if (obj) {
                if (masterSink !== obj) {
                    masterSink = obj
                }
                return true
            }
        }
        // 3) Fallback
        if (PreferredDevice.sink) {
            if (masterSink !== PreferredDevice.sink) {
                masterSink = PreferredDevice.sink
            }
            return !!masterSink
        }
        return !!masterSink
    }

    Timer {
        id: finder
        interval: 50
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (findMaster()) {
                finder.stop()
            }
        }
    }

    Connections {
        target: PreferredDevice
        function onSinkChanged() { findMaster() }
    }

    Connections {
        target: rawSinkModel
        function onModelReset() { findMaster() }
        function onRowsInserted() { findMaster() }
        function onRowsRemoved() { findMaster() }
    }

    // Sinks always have a volume; only streams may lack it (PulseAudioQt API)
    readonly property int masterPercent: masterSink
        ? Math.round((masterSink.volume / PulseAudio.NormalVolume) * 100.0)
        : 0
    readonly property bool masterMuted: masterSink ? masterSink.muted : false

    readonly property int appRowHeight: 56 + Kirigami.Units.smallSpacing
    readonly property int contentHeight: 64
        + (sinkInputModel.count > 0 ? (1 + Kirigami.Units.smallSpacing) : 0)
        + (sinkInputModel.count * appRowHeight)
        + (Kirigami.Units.smallSpacing * 2)

    implicitHeight: contentHeight

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        Item {
            id: masterHeader
            Layout.fillWidth: true
            implicitHeight: 64

            RowLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    source: "audio-card"
                    opacity: masterMuted || !masterSink ? 0.5 : 1.0
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: i18n("Master")
                        font.bold: true
                        elide: Text.ElideRight
                        opacity: masterMuted || !masterSink ? 0.7 : 1.0
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        PlasmaComponents3.Slider {
                            id: masterSlider

                            readonly property var sink: root.masterSink

                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            stepSize: 1
                            enabled: sink && sink.volumeWritable

                            // Bound directly to the real sink volume, as the official applet does
                            value: sink ? Math.round((sink.volume / PulseAudio.NormalVolume) * 100.0) : 0

                            onPressedChanged: {
                                if (!pressed && sink) {
                                    // Ripristina il binding al valore reale del sink dopo il drag
                                    value = Qt.binding(function() {
                                        if (!sink) return 0
                                        return Math.round((sink.volume / PulseAudio.NormalVolume) * 100.0)
                                    })
                                }
                            }

                            onMoved: {
                                if (sink && sink.volumeWritable) {
                                    sink.volume = Math.round((value / 100.0) * PulseAudio.NormalVolume)
                                    if (value === 0) {
                                        sink.muted = true
                                    } else if (sink.muted) {
                                        sink.muted = false
                                    }
                                }
                            }
                        }

                        PlasmaComponents3.Label {
                            Layout.preferredWidth: 38
                            horizontalAlignment: Text.AlignRight
                            text: root.masterPercent + "%"
                            font.pixelSize: PlasmaCore.Units.fontPixelSize * 0.9
                            opacity: masterMuted || !masterSink ? 0.5 : 0.85
                        }

                        PlasmaComponents3.ToolButton {
                            icon.name: masterMuted ? "audio-volume-muted" : "audio-volume-high"
                            enabled: !!masterSink
                            onClicked: {
                                if (masterSink) {
                                    masterSink.muted = !masterSink.muted
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            height: 1
            color: PlasmaCore.ColorScope.textColor
            opacity: 0.15
            visible: sinkInputModel.count > 0
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.sinkInputModel
            spacing: Kirigami.Units.smallSpacing
            clip: true

            delegate: AppRow {
                id: row
                required property int index
                required property var model

                readonly property var stream: model.PulseObject

                width: ListView.view ? ListView.view.width : 0
                appName: (stream && (stream.properties["application.name"] || stream.name || stream.description)) || model.Name || i18n("Unknown App")
                appIcon: (stream && (stream.properties["application.icon_name"] || stream.iconName)) || "application-x-executable"
                volumePercent: stream && stream.hasVolume ? Math.round((stream.volume / PulseAudio.NormalVolume) * 100.0) : 0
                muted: stream ? stream.muted : false
                hasVolume: stream ? stream.hasVolume : true
                corked: stream ? stream.corked : false

                // Written on every movement (no debounce): volume follows the drag continuously
                onUserVolumeChanged: (val) => {
                    if (row.stream && row.stream.volumeWritable) {
                        row.stream.volume = Math.round((val / 100.0) * PulseAudio.NormalVolume)
                    }
                }
                onUserMuteToggled: () => {
                    if (row.stream) row.stream.muted = !row.stream.muted
                }
            }

            Controls.ScrollBar.vertical: Controls.ScrollBar {
                policy: Controls.ScrollBar.AsNeeded
            }
        }
    }
}
