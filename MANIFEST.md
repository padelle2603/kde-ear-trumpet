# Project Manifest

## Origin & Motivation

On Windows, the popular open-source utility **EarTrumpet** provides an intuitive, uncluttered audio mixer: clicking the tray icon instantly reveals active applications alongside master volume controls without unnecessary submenus or tabbed clutter.

In the Linux ecosystem, the official KDE Plasma audio widget (`plasma-pa`) is feature-rich but relies on tabbed navigation, separate device pages, and a fixed, multi-layered layout. Users who simply want to glance at active audio streams and adjust per-app volume along with the system master volume often find the official flow unnecessarily complex.

**kde-ear-trumpet** was built to provide that missing experience on KDE Plasma 6: a compact panel icon that expands on click into an auto-sizing dropdown listing active playing applications and master volume in a single, focused view.

## Vision & Principles

1. **Native Integration First (Breeze / Kirigami):** We do not emulate Windows Fluent Design. The widget adapts seamlessly to your active Plasma theme, palette, typography, margins, and dark/light mode.
2. **Zero Bloat & Zero External Dependencies:** No external binary daemons, no C++ compilation required, and no non-standard libraries. The plasmoid runs on pure QML utilizing the private volume subsystem already installed with Plasma 6 (`plasma-pa`).
3. **Single Focused Surface (KISS):** No separate tabs for devices or stream routing. Everything essential (Master volume + active app volumes + mute toggles) is immediately accessible upon opening.
4. **Dynamic Geometry:** The popup footprint hugs its actual content instead of enforcing arbitrary fixed dimensions. With fewer apps playing, the popup stays minimal; with many, it provides smooth scrolling.
5. **Full Privacy by Default:** Local audio socket communication only. Zero network requests, zero telemetry.

## Maintainer

Maintained by Paolo D'Elia ([@padelle](https://github.com/padelle)).

## Cross-References

- [README.md](README.md) — Technical details, installation, and usage.
- [LICENSE](LICENSE) — GNU General Public License v3 or later.
- [PRIVACY.md](PRIVACY.md) — Data processing and local storage declaration.
- [LEGAL.md](LEGAL.md) — Trademarks and legal disclaimers.
