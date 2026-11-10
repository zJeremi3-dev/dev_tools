# Dev-Tools

![CI](https://github.com/zJeremi3-dev/dev_tools/actions/workflows/ci.yml/badge.svg)

A local-first Flutter app bundling 17 developer tools in one place — no account, no cloud, no tracking. Your data stays on your device;
the few features that need the internet are optional and listed under [Network usage](#network-usage).

## Features

| Category | Tools                                                                                |
|---|--------------------------------------------------------------------------------------|
| Generator | Password Generator, QR-Code Generator, Barcode Generator, Randomizer, UUID Generator |
| Converter | Bin ↔ Dec, Base64, URL Encoder, Unix-Timestamp, File Converter                       |
| Security | PW-Strength-Test, Hash Generator, RSA Key-Pair, IP-Leak Check                        |
| Text | JSON Formatter, Regex Tester                                                         |
| Design | Color Picker                                                                         |

Additional app-level features: favorites, hide/unhide tools, drag & drop reordering, 3 layout modes (custom grid, per-category grid, category-dropdown/tabular), 16 color schemes plus custom schemes you can add yourself, fully responsive UI.

## Why (mostly) offline

This app is meant to be a personal toolbox that works instantly, without setup
or an account. All state (favorites, order, hidden tools, layout, color scheme)
is persisted locally via `shared_preferences` — no backend, no sync, by design.

The exceptions are listed under [Network usage](#network-usage).

## Network usage

Dev-Tools works offline, except for these features, which contact third-party services:

| Feature | Service | What is sent | When |
|---|---|---|---|
| Update check | api.github.com | A plain GET request, no user data | On app start |
| IP-Leak-Check | ipapi.co | Your IP is visible to the service (that is what the tool checks) | Only when you run the tool |
| IP-Leak-Check (flag icons) | flagcdn.com | An image request (your IP is visible to the host) | Only when a result is shown |

The **Disable Online Modules** setting hides every tool that needs the internet
(currently only IP-Leak-Check, including its flag icons).
The update check is separate and can be turned off via **Disable Update Check**.

## Tech stack

- **Flutter** — UI framework
- **Riverpod** — state management (`ChangeNotifierProvider` wrapping a plain `ChangeNotifier` controller)
- **shared_preferences** — local persistence
- Package-specific tools per module (`crypto` for hashing, `qr`/`barcode_widget` for codes, etc.)

## Architecture

```
lib/
  models/         Pure data classes (ToolModule)
  data/           Static tool/category definitions + persistence (DatenManager)
  state/          ToolsController (business logic, UI-independent) + Riverpod providers
  widgets/        Reusable, dumb UI pieces (ToolCard, CategoryDropdownColumn, ...)
  app/            Screen composition (MyHomePage)
  settings/       Settings dialog and its sections
  modules/        The 17 individual tool dialogs
  services/       The updater
```

The guiding principle: each layer has exactly one reason to change. `ToolsController` holds all app state and logic and knows nothing about Flutter widgets — this is what makes it directly unit-testable without spinning up any UI. Riverpod's `ChangeNotifierProvider` exposes that controller to the widget tree without manual prop-drilling.


## Download

Grab the latest Windows installer from the [Releases page](https://github.com/zJeremi3-dev/dev_tools/releases/latest).
Currently, Windows-only; other platforms may follow. The installer is built with
[Inno Setup](https://jrsoftware.org/isinfo.php). The app checks for updates on
startup and can update itself in place.

> **Windows security warning:** SmartScreen may warn about an "unknown publisher".
> This is expected for small open-source projects without a paid code-signing
> certificate and does **not** mean the file is malicious. The installer is built
> transparently from this repository via GitHub Actions
> (see `.github/workflows/release.yml`). Click **"More info" → "Run anyway"**.


## Getting started

```
flutter pub get
flutter run
```

## Testing

```
flutter analyze
flutter test
```

The test suite covers:
- `ToolsController` — favorites, hide/unhide, search/filter, all three reorder variants, persistence round-trips, including color scheme restoration
  - Data integrity of the static tool/category list
- `DatenManager` persistence, including malformed-data handling
- All 17 tool modules (password generator, converters, hash generator, UUID generator, regex tester, RSA tester mode, etc.)
- `ToolCard` and all settings widgets (`SettingsDialog`, `HiddenModulesSection`, `ModuleLayoutSection`, `ColorSchemeDialog`, `SchemeAdder`)
- A full app smoke test (`home_page_smoke_test.dart`) covering load, search, and opening settings

Not yet covered: RSA key *generation* itself (only the encrypt/decrypt tester mode is tested — key generation runs an expensive isolate-based prime search unsuited to a fast test suite).

## Licenses

This app bundles several open-source packages (Riverpod, crypto, qr,
barcode_widget, etc.), each under its own open-source license (e.g. MIT, BSD, Apache 2.0).
Full license texts are viewable in-app under **Settings → Licenses**.


## Known limitations / roadmap

- Color scheme is implemented via global mutable variables (`colors.dart`) rather than a fully Riverpod-driven theme — a pragmatic tradeoff for a single-screen app, flagged as technical debt rather than hidden.
- No integration or golden (screenshot) tests yet.