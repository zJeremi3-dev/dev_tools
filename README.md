# Dev-Tools

![CI](https://github.com/zJeremi3-dev/dev_tools/actions/workflows/ci.yml/badge.svg)

A local-first Flutter desktop/mobile app bundling 15 everyday developer tools in one place — no account, no cloud, no tracking. Everything runs and is stored entirely on-device.

## Features

| Category | Tools |
|---|---|
| Generator | Password Generator, QR-Code Generator, Barcode Generator, Randomizer, UUID Generator |
| Converter | Bin ↔ Dec, Base64, URL Encoder, Unix-Timestamp |
| Security | PW-Strength-Test, Hash Generator, RSA Key-Pair |
| Text | JSON Formatter, Regex Tester |
| Design | Color Picker |

Additional app-level features: favorites, hide/unhide tools, drag & drop reordering, 3 layout modes (custom grid, per-category grid, category-dropdown/tabular), 16 color schemes, fully responsive UI.

## Why (mostly) offline

This app is meant to be a personal toolbox that works instantly, without setup
or an account. All state (favorites, order, hidden tools, layout, color scheme)
is persisted locally via `shared_preferences` — no backend, no sync, by design.

The one exception: on startup, the app makes a single passive GET request to
GitHub's public releases API to check for a newer version. No user data is
sent. See `lib/services/update_checker.dart`.

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
  modules/        The 15 individual tool dialogs
  services/       The updater
```

The guiding principle: each layer has exactly one reason to change. `ToolsController` holds all app state and logic and knows nothing about Flutter widgets — this is what makes it directly unit-testable without spinning up any UI. Riverpod's `ChangeNotifierProvider` exposes that controller to the widget tree without manual prop-drilling.

Installer built with `Inno Setup`

## Download

Grab the latest Windows installer from the [Releases page](https://github.com/zJeremi3-dev/dev_tools/releases/latest).
Currently, Windows-only; other platforms may follow.

The app checks for updates automatically and can update itself in place.
    
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
- All 15 tool modules (password generator, converters, hash generator, UUID generator, regex tester, RSA tester mode, etc.)
- `ToolCard` and all settings widgets (`SettingsDialog`, `HiddenModulesSection`, `ModuleLayoutSection`, `ColorSchemeDialog`)
- A full app smoke test (`home_page_smoke_test.dart`) covering load, search, and opening settings

Not yet covered: RSA key *generation* itself (only the encrypt/decrypt tester mode is tested — key generation runs an expensive isolate-based prime search unsuited to a fast test suite).

## Licenses

This app bundles several open-source packages (Riverpod, crypto, qr,
barcode_widget, etc.), each under its own permissive license (MIT/BSD).
Full license texts are viewable in-app under **Settings → Licenses**.


## Known limitations / roadmap

- Color scheme is implemented via global mutable variables (`colors.dart`) rather than a fully Riverpod-driven theme — a pragmatic tradeoff for a single-screen app, flagged as technical debt rather than hidden.
- Test coverage is partial (see above).

## A note on the Windows security warning

Windows SmartScreen may warn that this installer is from an "unknown
publisher." This is expected for small open-source projects without a
paid code-signing certificate — it does **not** mean the file is
malicious. The installer is built automatically and transparently from
this repository's source via GitHub Actions (see `.github/workflows/release.yml`).

If you see the warning: click **"More info" → "Run anyway"**.