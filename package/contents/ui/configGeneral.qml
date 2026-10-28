import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.private.volume
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    property alias cfg_scrollStep: scrollStepSpin.value
    property alias cfg_showVirtualDevices: showVirtualSwitch.checked
    property string cfg_preferredSinkName: ""

    SinkModel {
        id: sinkModel
        onCountChanged: sinkCombo.reload()
    }

    Kirigami.FormLayout {
        Layout.alignment: Qt.AlignTop

        PlasmaComponents3.ComboBox {
            id: sinkCombo
            Kirigami.FormData.label: i18n("Master Output Device:")
            Layout.fillWidth: true
            textRole: "display"
            valueRole: "name"

            model: ListModel {
                id: sinkListModel
            }

            function reload() {
                const currentSelected = root.cfg_preferredSinkName
                sinkListModel.clear()

                sinkListModel.append({
                    "display": i18n("System Default (Automatic)"),
                                     "name": ""
                })

                for (let i = 0; i < sinkModel.count; ++i) {
                    const idx = sinkModel.index(i, 0)
                    const obj = sinkModel.data(idx, sinkModel.role("PulseObject"))
                    if (obj) {
                        if (!root.cfg_showVirtualDevices && obj.virtualDevice) {
                            continue
                        }
                        const label = (obj.description && obj.description.length > 0)
                        ? obj.description
                        : (obj.name || i18n("Unknown"))
                        sinkListModel.append({
                            "display": label,
                            "name": obj.name
                        })
                    }
                }

                // Sincronizza l'indice con il valore salvato
                let targetIdx = 0
                for (let i = 0; i < sinkListModel.count; ++i) {
                    if (sinkListModel.get(i).name === currentSelected) {
                        targetIdx = i
                        break
                    }
                }
                sinkCombo.currentIndex = targetIdx
            }

            onActivated: {
                const item = sinkListModel.get(currentIndex)
                root.cfg_preferredSinkName = item ? item.name : ""
            }

            Component.onCompleted: reload()
        }

        PlasmaComponents3.SpinBox {
            id: scrollStepSpin
            Kirigami.FormData.label: i18n("Scroll Step:")
            from: 1
            to: 25
        }

        PlasmaComponents3.Switch {
            id: showVirtualSwitch
            Kirigami.FormData.label: i18n("Show Virtual Devices:")
            text: i18n("Include virtual sinks (e.g. Easy Effects)")
            onCheckedChanged: sinkCombo.reload()
        }
    }

    Connections {
        target: sinkModel
        function onModelReset() { sinkCombo.reload() }
        function onRowsInserted() { sinkCombo.reload() }
        function onRowsRemoved() { sinkCombo.reload() }
        function onDataChanged() { sinkCombo.reload() }
    }
}
