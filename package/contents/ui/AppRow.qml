import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: root

    property string appName: ""
    property string appIcon: ""
    property int volumePercent: 50
    property bool muted: false
    property bool hasVolume: true
    property bool corked: false

    signal userVolumeChanged(int value)
    signal userMuteToggled()

    implicitHeight: 56
    implicitWidth: ListView.view ? ListView.view.width : 280

    RowLayout {
        anchors.fill: parent
        anchors.margins: PlasmaCore.Units.smallSpacing
        spacing: PlasmaCore.Units.smallSpacing

        Kirigami.Icon {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            source: root.appIcon
            opacity: root.muted || root.corked ? 0.5 : 1.0
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                text: root.appName
                elide: Text.ElideRight
                opacity: root.muted || root.corked ? 0.7 : 1.0
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: PlasmaCore.Units.smallSpacing

                PlasmaComponents3.Slider {
                    id: slider
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    stepSize: 1
                    value: root.volumePercent
                    enabled: root.hasVolume
                    onMoved: {
                        root.userVolumeChanged(Math.round(slider.value))
                    }
                    onPressedChanged: {
                        if (!pressed) {
                            // Re-bind to the real stream volume once the drag ends
                            value = Qt.binding(function() { return root.volumePercent })
                        }
                    }
                }

                PlasmaComponents3.Label {
                    Layout.preferredWidth: 38
                    horizontalAlignment: Text.AlignRight
                    text: root.volumePercent + "%"
                    font.pixelSize: PlasmaCore.Units.fontPixelSize * 0.9
                    opacity: root.muted || root.corked ? 0.5 : 0.85
                }

                PlasmaComponents3.ToolButton {
                    icon.name: root.muted ? "audio-volume-muted" : "audio-volume-high"
                    onClicked: root.userMuteToggled()
                    enabled: root.hasVolume
                }
            }
        }
    }
}
