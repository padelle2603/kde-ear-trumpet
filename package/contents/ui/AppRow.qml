import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: root

    property string appName: ""
    property string appIcon: ""
    property var stream: null

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
            opacity: (root.stream && (root.stream.muted || root.stream.corked)) ? 0.5 : 1.0
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                text: root.appName
                elide: Text.ElideRight
                opacity: (root.stream && (root.stream.muted || root.stream.corked)) ? 0.7 : 1.0
            }

            VolumeSlider {
                Layout.fillWidth: true
                target: root.stream
                onMoved: (val) => root.userVolumeChanged(val)
                onMuteToggled: () => root.userMuteToggled()
            }
        }
    }
}
