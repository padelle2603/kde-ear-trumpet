import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.plasmoid
import org.kde.plasma.private.volume
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import "../code/appName.js" as AppName

Item {
    id: root

    readonly property SinkInputModel sinkInputModel: SinkInputModel {}
    readonly property SinkModel rawSinkModel: SinkModel {}

    // Configurazione sink preferito (vuoto = usa predefinito di sistema)
    readonly property string configuredSinkName: Plasmoid.configuration.preferredSinkName || ""
    readonly property bool showVirtualDevices: Plasmoid.configuration.showVirtualDevices || false

    property var masterSink: null

    /**
     * Determines which output sink should be treated as the master volume sink.
     * Priority chain:
     * 1) User-configured sink by name (if set in widget settings)
     * 2) System default sink (Server.defaultSink) — only if non-virtual or showVirtualDevices is enabled
     * 3) PreferredDevice.sink — only if non-virtual or showVirtualDevices is enabled
     * 4) First non-virtual physical sink found in rawSinkModel
     * 5) Fallback: Server.defaultSink or PreferredDevice.sink even if virtual
     * 6) Absolute fallback: first available sink in rawSinkModel regardless of type
     */
    function updateMasterSink() {
        // 1) Se specificato nelle impostazioni dell'utente, cerca per nome esatto
        if (configuredSinkName.length > 0) {
            for (let i = 0; i < rawSinkModel.count; ++i) {
                const idx = rawSinkModel.index(i, 0)
                const obj = rawSinkModel.data(idx, rawSinkModel.role("PulseObject"))
                if (obj && obj.name === configuredSinkName) {
                    masterSink = obj
                    return
                }
            }
        }

        // Helper per verificare se un sink è accettabile rispetto al filtro virtual devices
        function isSinkAcceptable(sink) {
            if (!sink) return false
            if (showVirtualDevices) return true
            return !sink.virtualDevice
        }

        // 2) Dispositivo in linea d'uscita predefinito di sistema
        if (Server.defaultSink && isSinkAcceptable(Server.defaultSink)) {
            masterSink = Server.defaultSink
            return
        }

        // 3) PreferredDevice.sink
        if (PreferredDevice.sink && isSinkAcceptable(PreferredDevice.sink)) {
            masterSink = PreferredDevice.sink
            return
        }

        // 4) Primo sink non virtuale nel modello
        for (let i = 0; i < rawSinkModel.count; ++i) {
            const idx = rawSinkModel.index(i, 0)
            const obj = rawSinkModel.data(idx, rawSinkModel.role("PulseObject"))
            if (obj && !obj.virtualDevice) {
                masterSink = obj
                return
            }
        }

        // 5) Fallback se tutti i sink sono virtuali o nessun fisico trovato:
        // accetta Server.defaultSink o PreferredDevice.sink
        if (Server.defaultSink) {
            masterSink = Server.defaultSink
            return
        }
        if (PreferredDevice.sink) {
            masterSink = PreferredDevice.sink
            return
        }

        // 6) Fallback assoluto: primo sink qualunque
        if (rawSinkModel.count > 0) {
            const idx = rawSinkModel.index(0, 0)
            masterSink = rawSinkModel.data(idx, rawSinkModel.role("PulseObject"))
            return
        }

        masterSink = null
    }

    Connections {
        target: Server
        function onDefaultSinkChanged() { updateMasterSink() }
    }

    Connections {
        target: PreferredDevice
        function onSinkChanged() { updateMasterSink() }
    }

    Connections {
        target: rawSinkModel
        function onModelReset() { updateMasterSink() }
        function onRowsInserted() { updateMasterSink() }
        function onRowsRemoved() { updateMasterSink() }
        function onDataChanged() { updateMasterSink() }
    }

    Connections {
        target: Plasmoid.configuration
        function onPreferredSinkNameChanged() { updateMasterSink() }
        function onShowVirtualDevicesChanged() { updateMasterSink() }
    }

    Component.onCompleted: {
        updateMasterSink()
    }

    readonly property bool masterMuted: masterSink ? masterSink.muted : false

    readonly property int naturalHeight: masterHeader.implicitHeight
        + (divider.visible ? (divider.height + Kirigami.Units.smallSpacing) : 0)
        + (sinkInputModel.count > 0 ? (listView.contentHeight + Kirigami.Units.smallSpacing) : 0)
        + (Kirigami.Units.smallSpacing * 2)

    implicitHeight: naturalHeight

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
                    source: (masterSink && masterSink.iconName) ? masterSink.iconName : "audio-card"
                    opacity: masterMuted || !masterSink ? 0.5 : 1.0
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        PlasmaComponents3.Label {
                            Layout.fillWidth: true
                            text: masterSink ? (masterSink.description || masterSink.name || i18n("Master")) : i18n("Master")
                            font.bold: true
                            elide: Text.ElideRight
                            opacity: masterMuted || !masterSink ? 0.7 : 1.0
                        }

                        Rectangle {
                            visible: !!(masterSink && masterSink.virtualDevice)
                            implicitHeight: Math.round(Kirigami.Units.gridUnit * 0.9)
                            implicitWidth: virtualLabel.implicitWidth + (Kirigami.Units.smallSpacing * 2)
                            radius: Kirigami.Units.cornerRadius
                            color: Kirigami.Theme.highlightColor

                            PlasmaComponents3.Label {
                                id: virtualLabel
                                anchors.centerIn: parent
                                text: i18n("Virtual")
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                                font.bold: true
                                color: "#FFFFFF"
                            }
                        }
                    }

                    VolumeSlider {
                        Layout.fillWidth: true
                        target: root.masterSink
                    }
                }
            }
        }

        Rectangle {
            id: divider
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            height: 1
            color: Kirigami.Theme.textColor
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

                readonly property var streamObj: model.PulseObject

                width: ListView.view ? ListView.view.width : 0
                appName: AppName.resolveName(streamObj, model)
                appIcon: AppName.resolveIcon(streamObj)
                stream: streamObj
            }

            Controls.ScrollBar.vertical: Controls.ScrollBar {
                policy: Controls.ScrollBar.AsNeeded
            }
        }
    }
}
