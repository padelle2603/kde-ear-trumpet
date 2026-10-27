import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils
import org.kde.config as KConfig

PlasmoidItem {
    id: root

    preferredRepresentation: compactRepresentation

    // Soglie ufficiali per la commutazione compact/full in base a Kirigami Units
    switchWidth: Kirigami.Units.gridUnit * 14
    switchHeight: Kirigami.Units.gridUnit * 8

    compactRepresentation: MouseArea {
        id: compactRoot
        implicitWidth: Kirigami.Units.iconSizes.smallMedium
        implicitHeight: Kirigami.Units.iconSizes.smallMedium

        onClicked: root.expanded = !root.expanded

        Kirigami.Icon {
            anchors.fill: parent
            source: "speaker"
        }
    }

    fullRepresentation: PlasmaExtras.Representation {
        id: fullRep

        collapseMarginsHint: true

        Layout.minimumWidth: Kirigami.Units.gridUnit * 16
        Layout.preferredWidth: Kirigami.Units.gridUnit * 20
        Layout.maximumWidth: Kirigami.Units.gridUnit * 24

        // Altezza ancorata dinamicamente al contenuto della lista:
        // Altezza minima = altezza master header (~68)
        // Altezza desiderata = altezza reale del contenuto
        // Altezza massima = 520 (oltre cui scatta lo scorrimento)
        Layout.minimumHeight: Math.min(appsPage.contentHeight, 520)
        Layout.preferredHeight: Math.min(appsPage.contentHeight, 520)
        Layout.maximumHeight: 520

        contentItem: AppsPage {
            id: appsPage
        }
    }

    // Adds "Configure Audio Devices…" to the plasmoid context menu (same as plasma-pa)
    PlasmaCore.Action {
        id: configureAudioDevicesAction
        text: i18n("&Configure Audio Devices…")
        icon.name: "configure"
        visible: KConfig.KAuthorized.authorizeControlModule("kcm_pulseaudio")
        onTriggered: KCMUtils.KCMLauncher.openSystemSettings("kcm_pulseaudio")
    }

    Component.onCompleted: {
        Plasmoid.setInternalAction("configure", configureAudioDevicesAction)
    }
}
