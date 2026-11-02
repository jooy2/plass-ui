# Examples

Two small apps built with Plass, for trying the libraries the way a consumer uses them. `packages/flutter/example` and the demos in `docs/` show one component at a time; these put components together on real screens, on the platforms the documentation site cannot show.

Each app has two halves:

- **Screens of a real app**: a dashboard, an inbox, a form, overlays and settings. Tests drive these the way a person does.
- **Every component demo**: the same files the documentation shows, so a component can be looked at on a device on its own.

None of this is published to npm or pub.dev.

## Flutter: `examples/flutter`

iOS, iPadOS and Android. It needs Flutter and either Xcode or the Android SDK.

```bash
cd examples/flutter
flutter pub get
flutter devices
flutter run -d <device>
```

Five destinations are in the bottom bar on a phone and in a sidebar on a tablet. **More** leads to the overlays, the media screen and **Components**, which holds every demo. The theme, the direction, the density, the label language and the text size are on the same screen.

The iOS project's deployment target is 15.0, because Xcode 27 refuses the 13.0 that `flutter create` still writes.

### Tests

On the host, which is what CI runs:

```bash
flutter test
```

`test/app_test.dart` runs the flows in `integration_test/flows.dart` at the size of a phone and of a tablet. `test/demos_test.dart` lays out every demo at three screen widths and fails on any overflow or exception.

On a simulator or an emulator, which is what shows how the device's own renderer draws them:

```bash
flutter drive --driver test_driver/integration_test.dart --target integration_test/app_test.dart --keep-app-running -d <device>
```

```bash
flutter drive --driver test_driver/integration_test.dart --target integration_test/demos_test.dart --keep-app-running -d <device>
```

Both save a screenshot of every step inside the app, and `--keep-app-running` keeps the app so they can be copied off:

```bash
tool/pull_screenshots.sh ios <simulator id> <folder>
```

```bash
tool/pull_screenshots.sh android <emulator serial> <folder>
```

On a real iPhone, pass your own signing team, since the project holds none, and run in profile mode, which draws what a user's phone draws. Keep the phone unlocked, and allow the Local Network prompt on the first run:

```bash
FLUTTER_XCODE_DEVELOPMENT_TEAM=<team id> flutter drive --driver test_driver/integration_test.dart --target integration_test/app_test.dart --keep-app-running --profile -d <device>
```

```bash
tool/pull_screenshots.sh ios-device <device id> <folder>
```

`--dart-define=PLASS_THEME=dark` runs the demos in the dark theme, `--dart-define=PLASS_DEMOS=button,text-field` runs some of the components, and `--dart-define=PLASS_SETTLE_MS=2000` gives each demo longer to settle, which a picture off the network needs.

## Electron: `examples/electron`

The React package in a window with the sandbox on, context isolation on, a Content Security Policy, and a `plass://` scheme of its own rather than `file://`. It installs `plass-ui` from `packages/react`, so build that first:

```bash
cd packages/react
npm install
npm run build
```

```bash
cd examples/electron
npm install
npm run dev
```

The sidebar holds the documentation's whole-screen examples, an inbox, the overlays, a screen of what only a desktop app does (files from the disk, code highlighted from a chunk loaded on demand, the clipboard) and **Components**, which holds every demo.

### Tests

```bash
npm test
```

`test/app.spec.ts` drives the built app through Playwright and fails on any console error, and `test/demos.spec.ts` opens every demo. Setting `PLASS_SHOTS=1` saves a screenshot of each one under `shots/`.
