import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.plasmoid
import org.kde.plasma.private.volume
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: root

    readonly property SinkInputModel sinkInputModel: SinkInputModel {}
    readonly property SinkModel rawSinkModel: SinkModel {}

    // Configurazione sink preferito (vuoto = usa predefinito di sistema)
    readonly property string configuredSinkName: Plasmoid.configuration.preferredSinkName || ""

    property var masterSink: null

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

        // 2) Dispositivo in linea d'uscita predefinito di sistema
        if (Server.defaultSink) {
            masterSink = Server.defaultSink
            return
        }

        // 3) PreferredDevice.sink
        if (PreferredDevice.sink) {
            masterSink = PreferredDevice.sink
            return
        }

        // 4) Primo sink non virtuale
        for (let i = 0; i < rawSinkModel.count; ++i) {
            const idx = rawSinkModel.index(i, 0)
            const obj = rawSinkModel.data(idx, rawSinkModel.role("PulseObject"))
            if (obj && !obj.virtualDevice) {
                masterSink = obj
                return
            }
        }

        // 5) Fallback assoluto: primo sink qualunque
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

                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: masterSink ? (masterSink.description || masterSink.name || i18n("Master")) : i18n("Master")
                        font.bold: true
                        elide: Text.ElideRight
                        opacity: masterMuted || !masterSink ? 0.7 : 1.0
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

                readonly property var streamObj: model.PulseObject

                width: ListView.view ? ListView.view.width : 0
                appName: (streamObj && (streamObj.properties["application.name"] || streamObj.name || streamObj.description)) || model.Name || i18n("Unknown App")
                appIcon: {
                    if (!streamObj) return "application-x-executable"
                    const props = streamObj.properties || {}
                    const clientProps = (streamObj.client && streamObj.client.properties) || {}
                    
                    return props["application.icon_name"]
                        || clientProps["application.icon_name"]
                        || streamObj.iconName
                        || (streamObj.client && streamObj.client.iconName)
                        || props["window.icon_name"]
                        || clientProps["window.icon_name"]
                        || props["media.icon_name"]
                        || clientProps["media.icon_name"]
                        || "application-x-executable"
                }
                stream: streamObj
            }

            Controls.ScrollBar.vertical: Controls.ScrollBar {
                policy: Controls.ScrollBar.AsNeeded
            }
        }
    }
}
