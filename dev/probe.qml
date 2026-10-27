import QtQuick 6.0
import QtQuick.Layouts 1.0
import org.kde.plasma.plasmoid
import org.kde.plasma.private.volume
import org.kde.kitemmodels as KItemModels

PlasmoidItem {
    id: root

    width: 600 * PlasmaCore.Units.devicePixelRatio
    height: 400 * PlasmaCore.Units.devicePixelRatio
    Layout.minimumWidth: width
    Layout.minimumHeight: height

    // Modello
    property var sinkInputModel: SinkInputModel {}
    property var sinkModel: SinkModel {}
    property var server: Server {}

    // Proxy per filtro dummy
    property var filterModel: KItemModels.KSortFilterProxyModel {
        sourceModel: sinkInputModel
        filterRole: "Name"
        filterFixedString: "auto_null"
    }

    Component.onCompleted: {
        // --- Probe Server singleton ---
        console.log("=== Server singleton ===");
        console.log("defaultSink:", server.defaultSink ? server.defaultSink.description : "null");
        console.log("defaultSource:", server.defaultSource ? server.defaultSource.description : "null");
        console.log("isPipeWire:", server.isPipeWire);
        console.log("hasWirePlumber:", server.hasWirePlumber);
        console.log("version:", server.version);
        console.log("wirePlumberVersion:", server.hasWirePlumber ? server.wirePlumberVersion : "N/A");

        // --- Probe SinkModel ---
        console.log("\n=== SinkModel (", sinkModel.rowCount(), "items) ===");
        for (let i = 0; i < sinkModel.rowCount(); ++i) {
            const idx = sinkModel.index(i, 0);
            const obj = sinkModel.data(idx, sinkModel.role("PulseObject"));
            if (!obj) continue;
            console.log("Sink #", i);
            console.log("  Name:", obj.name);
            console.log("  Description:", obj.description);
            console.log("  IconName:", obj.iconName);
            console.log("  State:", obj.state);
            console.log("  FormFactor:", obj.formFactor);
            console.log("  Default:", obj.default);
            console.log("  CardIndex:", obj.cardIndex);
            console.log("  ActivePortIndex:", obj.activePortIndex);
            console.log("  BaseVolume:", obj.baseVolume);
            console.log("  Ports length:", obj.ports.length);
            // Prova a leggere volume/mute tramite VolumeMonitor
            const vm = VolumeMonitor {}
            vm.target = obj;
            console.log("  VolumeMonitor.volume:", vm.volume);
            console.log("  VolumeMonitor.muted:", vm.muted);
            vm.destroy();
        }

        // --- Probe SinkInputModel ---
        console.log("\n=== SinkInputModel (", sinkInputModel.rowCount(), "items) ===");
        for (let i = 0; i < sinkInputModel.rowCount(); ++i) {
            const idx = sinkInputModel.index(i, 0);
            const obj = sinkInputModel.data(idx, sinkInputModel.role("PulseObject"));
            if (!obj) continue;
            const stream = obj;
            console.log("SinkInput #", i);
            console.log("  Name:", obj.name);
            console.log("  Description:", obj.description);
            console.log("  IconName:", obj.iconName);
            console.log("  DeviceIndex:", stream.deviceIndex);
            console.log("  Client:", stream.client ? stream.client.description : "null");
            console.log("  VirtualStream:", stream.virtualStream);
            console.log("  corked:", stream.corked);
            console.log("  hasVolume:", stream.hasVolume);
            // Volume/Mute tramite VolumeMonitor
            const vm = VolumeMonitor {}
            vm.target = obj;
            console.log("  VolumeMonitor.volume:", vm.volume);
            console.log("  VolumeMonitor.muted:", vm.muted);
            vm.destroy();
        }

        // --- Ruoli disponibili in SinkInputModel ---
        console.log("\n=== Ruoli disponibili in SinkInputModel ===");
        const roles = sinkInputModel.roleNames();
        for (const key in roles) {
            console.log("  " + roles[key]);
        }
    }

    // UI di prova
    CompactRepresentation: Item {
        width: 40 * PlasmaCore.Units.devicePixelRatio
        height: 40 * PlasmaCore.Units.devicePixelRatio
        anchors.centerIn: parent
    }

    FullRepresentation: ColumnLayout {
        anchors.fill: parent
        spacing: PlasmaCore.Units.largeSpacing

        Label {
            text: "Probe API — Scheda Sink"
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: sinkModel
            delegate: RowLayout {
                spacing: PlasmaCore.Units.largeSpacing
                width: parent.width

                PlasmaComponents3.Icon {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    source: model.iconName || "speaker"
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    Label {
                        text: model.description || model.name || "Unknown"
                        font.bold: true
                    }

                    Label {
                        text: "Default: " + (model.default ? "sì" : "no")
                            + " | State: " + model.state
                    }

                    RowLayout {
                        spacing: 4
                        PlasmaComponents3.SpinBox {
                            from: 0
                            to: 100
                            value: model.volume
                            enabled: false
                        }
                        PlasmaComponents3.ToolButton {
                            icon.name: model.muted ? "audio-volume-muted" : "audio-volume-high"
                        }
                    }
                }
            }
        }
    }
}
