# Privacy Policy

**kde-ear-trumpet** is an EarTrumpet-style audio mixer plasmoid for KDE Plasma 6.

This software is built following strict privacy-by-design principles: it operates purely locally on your device.

## No Network Connections

- **No HTTP or network requests.** The plasmoid contains no network code, no HTTP client, no analytics, and no remote telemetry.
- **Zero data transmission.** No device metrics, volume levels, application lists, or diagnostic data are ever transmitted to any remote server or third party.

## Local Data & Storage

- **Audio routing state:** The plasmoid communicates exclusively with your local sound server (PipeWire / PulseAudio) via the native KDE Plasma Volume API (`org.kde.plasma.private.volume`).
- **Configuration:** Plasmoid preferences (such as pin state or compact/full sizing) are managed directly by KDE Plasma and stored locally in standard KDE configuration files under `~/.config/plasma-org.kde.plasma.desktop-appletsrc`.
- **No persistent tracking:** No application usage history or tracking logs are recorded or maintained on disk by this widget.

## Permissions

The plasmoid runs under standard user session permissions managed by KDE Plasma:
- Access to the local sound daemon session (PulseAudio/PipeWire IPC socket) to read and adjust audio levels.
- Access to local system settings via `kcm_pulseaudio` when explicitly requested through the context menu.

## Contact

For privacy or security concerns, open an issue on the project repository:
<https://github.com/padelle/kde-ear-trumpet/issues>

Refer to [LEGAL.md](LEGAL.md) for legal terms and [LICENSE](LICENSE) for licensing conditions.
