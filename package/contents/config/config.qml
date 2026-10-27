import QtQuick 6.0
import QtQuick.Layouts 1.0
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.config 2.0 as PlasmaConfig

Page {
    title: i18n("Configurazione")

    ColumnLayout {
        anchors.fill: parent
        spacing: PlasmaCore.Units.largeSpacing

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            text: i18n("Scheda generale")
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: PlasmaCore.Units.largeSpacing

            PlasmaComponents3.Label {
                text: i18n("Pagina predefinita:")
            }

            PlasmaComponents3.ComboBox {
                Layout.fillWidth: true
                model: [i18n("Apps"), i18n("Dispositivi")]
                currentIndex: config.defaultPage
                onCurrentIndexChanged: config.defaultPage = currentIndex
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: PlasmaCore.Units.largeSpacing

            PlasmaComponents3.Label {
                text: i18n("Passo scroll:")
            }

            PlasmaComponents3.SpinBox {
                Layout.fillWidth: true
                from: 1
                to: 25
                value: config.scrollStep
                onValueModified: config.scrollStep = value
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: PlasmaCore.Units.largeSpacing

            PlasmaComponents3.Label {
                text: i18n("Mostra dispositivi virtuali:")
            }

            PlasmaComponents3.Switch {
                Layout.fillWidth: true
                checked: config.showVirtualDevices
                onCheckedChanged: config.showVirtualDevices = checked
            }
        }
    }
}
