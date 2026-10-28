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

        // Altezza ancorata dinamicamente al contenuto della lista.
        // Tetto: 75% dello schermo disponibile (oltre scatta lo scrolling),
        // con fallback basato sulle grid unit se il rect non è ancora valido.
        readonly property int maxAvailableHeight: (root.availableScreenRect && root.availableScreenRect.height > 0)
            ? Math.round(root.availableScreenRect.height * 0.75)
            : (Kirigami.Units.gridUnit * 30)

        readonly property int popupHeight: Math.min(appsPage.naturalHeight, maxAvailableHeight)

        // AppletPopup salva popupWidth/popupHeight nel config dell'applet alla chiusura
        // e, se li trova al caricamento, disabilita per sempre l'auto-sizing
        // (m_sizeExplicitlySetFromConfig in appletpopup.cpp).
        // updateMinSize()/updateMaxSize() però non sono soggetti a quel flag:
        // pinnare min == max == popupHeight forza la finestra sulla dimensione
        // del contenuto in entrambe le direzioni, anche dopo un riavvio di plasmashell.
        Layout.minimumHeight: popupHeight
        Layout.preferredHeight: popupHeight
        Layout.maximumHeight: popupHeight
        implicitHeight: popupHeight

        contentItem: AppsPage {
            id: appsPage
        }
    }

    // Azione personalizzata nel menu contestuale per aprire le impostazioni audio di sistema
    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("&Configure Audio Devices…")
            icon.name: "preferences-desktop-sound"
            visible: KConfig.KAuthorized.authorizeControlModule("kcm_pulseaudio")
            onTriggered: KCMUtils.KCMLauncher.openSystemSettings("kcm_pulseaudio")
        }
    ]
}
