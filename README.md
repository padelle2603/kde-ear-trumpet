# kde-ear-trumpet

An EarTrumpet-style audio mixer plasmoid for KDE Plasma 6 that combines active app sliders and master volume in a single auto-sizing dropdown.

**KDE Plasma 6.0+ · PipeWire or PulseAudio · Pure QML (Zero C++ compilation) · English & Italian**

This widget lives as a single icon on your panel. Clicking it expands a dropdown showing the system master volume and every application currently playing audio, with real-time continuous sliders, mute controls, and responsive sizing.

---

## Audience Navigation

- **Users** — [Features](#features) · [Installation](#installation) · [What It Does Not Do](#what-it-does-not-do) · [Translations](#translations)
- **Developers & Packagers** — [Architecture & Requirements](#architecture--requirements) · [Development Testing](#development-testing)
- **Legal & Governance** — [License](#license) · [Privacy](#privacy) · [Manifest](#manifest) · [Legal](#legal)

---

## Features

- **Single unified view.** Master hardware volume and active application streams appear together in one vertical list without tabs.
- **Dynamic content sizing.** The popup dimensions hug the exact number of active apps instead of using a rigid predefined window height.
- **Continuous real-time control.** Volume adjustments write directly to the audio subsystem without debounce pauses or delayed steps.
- **Hardware-aware master control.** Intelligently binds to the physical audio output sink, even when virtual processing sinks (like EasyEffects) are present.
- **Native Breeze styling.** Inherits colors, fonts, geometry, and icons from your active Plasma theme in both light and dark modes.
- **Quick system settings access.** Right-clicking the plasmoid provides a direct shortcut to KDE's Audio System Settings module (`kcm_pulseaudio`).

---

## What It Does Not Do

- **It does not route streams across devices.** If you need to reassign individual applications to different output devices, use KDE's standard audio applet or System Settings.
- **It does not display non-playing applications.** Under PipeWire, audio streams are destroyed when playback stops; apps appear dynamically only while playing.
- **It does not include peak meters.** Real-time animated audio visualizer meters per app are omitted to preserve CPU efficiency and prevent rendering overhead.
- **It does not make network calls.** Zero external requests, telemetry, or update pingers.

---

## Installation

### 1. Requirements

Ensure you are running KDE Plasma 6 with standard audio integration:
- KDE Plasma `>= 6.0` (with `plasma-pa` package installed)
- PipeWire with WirePlumber or PulseAudio

### 2. Install the Plasmoid

Clone the repository and install the package using KDE's package tool:

```bash
git clone https://github.com/padelle/kde-ear-trumpet.git
cd kde-ear-trumpet
kpackagetool6 --type Plasma/Applet --install package
```

Alternatively, copy the `package` folder directly to your user plasmoids directory:

```bash
mkdir -p ~/.local/share/plasma/plasmoids/io.github.padelle.eartrumpet
cp -rf package/* ~/.local/share/plasma/plasmoids/io.github.padelle.eartrumpet/
```

### 3. Add to Panel

1. Right-click your KDE panel and choose **Enter Edit Mode** (or press `Meta+Alt+D`).
2. Click **Add Widgets…** and search for `kde-ear-trumpet`.
3. Drag the widget onto your desired panel location.

To update an existing installation after pulling changes:
```bash
kpackagetool6 --type Plasma/Applet --upgrade package
```
*(If updating, remove and re-add the widget to the panel once to clear Plasma's cached geometry).*

---

## Development & Testing

To run the plasmoid in an isolated preview window without modifying your desktop panel:

```bash
plasmawindowed io.github.padelle.eartrumpet
```

To validate QML syntax against Qt 6 / KDE 6 imports:

```bash
qmllint -I /usr/lib/qt6/qml package/contents/ui/*.qml
```

---

## Translations

The plasmoid supports native localization via gettext:
- **English** (default)
- **Italian** (`it_IT`)

Language selection is handled automatically by KDE based on your active system locale.

---

## Documents

- [LICENSE](LICENSE) — GNU General Public License v3 or later
- [PRIVACY.md](PRIVACY.md) — Privacy statement (zero network, zero data collection)
- [LEGAL.md](LEGAL.md) — Legal notices and trademark acknowledgments
- [MANIFEST.md](MANIFEST.md) — Project vision and design guidelines
