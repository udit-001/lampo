# AGENTS.md

## Overview

Flutter app for controlling WiZ smart bulbs over UDP (port 38899). Dart SDK ^3.12.2, Flutter 3.44.x.

## Architecture: MVVM

```
lib/
├── data/
│   ├── models/         # Bulb, BulbState, BulbCommand, BulbInfo, BulbEvent (freezed/sealed)
│   ├── repositories/   # BulbRepository — owns scan, reconcile, poll, command tracking
│   └── services/       # WizProtocol (abstract), WizProtocolImpl, FakeWizProtocol, Discovery, BulbStore
├── domain/
│   └── models/         # WizScene, SceneCategory
└── ui/
    ├── core/           # BulbColorSwatch, PreviewBox, AnimatedBadge, StaticBadge
    └── features/
        ├── home/       # HomeScreen, HomeViewModel
        └── bulb_detail/ # BulbDetailScreen, BulbDetailViewModel, ScenePickerScreen, DeviceInfoSheet
```

- **Data layer**: `BulbRepository` (no ChangeNotifier) — owns WizProtocol, Discovery, BulbStore, polling, reconciliation. Notifies via a listener list (`addListener`/`removeListener`/`_notifyListeners`) so multiple ViewModels receive updates simultaneously.
- **UI layer**: ViewModels extend `ChangeNotifier`, wrap Repository, register as listeners via `repository.addListener(notifyListeners)`. BulbDetailViewModel removes its listener on `dispose()` so HomeViewModel keeps receiving updates after the detail screen closes.
- **View layer**: Lean widgets using `ListenableBuilder` or `context.watch<T>()`.

## Key Design Decisions

- `BulbState` (snapshot) and `BulbCommand` (partial delta) are separate freezed types. `BulbState.merge(BulbCommand)` merges command into snapshot.
- `BulbState.fromMap(map, {previous})` merges into previous state using `containsKey` — absent keys preserve existing values.
- `WizProtocol` is abstract. `WizProtocolImpl` (real UDP) and `FakeWizProtocol` (in-memory) implement it. `sendAndWait` is private on the impl.
- `BulbEvent` is a sealed class: `StateUpdate`, `Registration`, `SyncPilot`.
- Discovery auto-detects the phone's subnet via `NetworkInterface.list()`.
- After scan, repository fetches `getPilotState` for each found bulb so the home list shows correct state immediately.
- Polling: 30s fallback (syncPilot provides near-instant push updates).
- Command tracking: pending commands checked against polled state after 10s — mismatch sets `commandFailed` flag.
- `isUserInteracting` flag on repository skips state merge during slider drag.

## Build & Test

```bash
dart run build_runner build          # regenerate freezed code after model changes
flutter analyze                       # zero issues required
flutter test                          # all tests required to pass
flutter build apk --debug             # build debug APK
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n com.lampo/.MainActivity
adb push build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/lampo.apk  # share APK
```

## Testing

- Hand-written fakes (FakeWizProtocol, FakeBulbStore, FakeDiscovery) — never mockito.
- Fakes live in `test/data/services/`, imported via relative paths.
- Test structure mirrors `lib/`.
- FakeWizProtocol tracks `sentCommands` and `registeredIps` for assertions.
- Broadcast streams are async by default — tests use `await Future.delayed(Duration.zero)` after `emitEvent()`.

## Issue Tracker

All work is tracked on the **lific** issue tracker (MCP-connected), project **WIZ**. Use `lific_*` tools to read issues, post comments, and update status.

## Workflow

1. Read the issue body for acceptance criteria
2. Set status to `active` via `lific_update_issue`
3. Implement
4. Run `flutter analyze` and `flutter test` — both must pass
5. Post a resolution comment via `lific_add_comment`
6. Set status to `done` via `lific_update_issue`

## Design System

- Material 3 with `ColorScheme.fromSeed(seedColor: Colors.deepPurple)`
- AppBar: `surfaceTintColor: Colors.transparent` (prevents scroll-through dimming)
- Custom buttons (mode toggle, filter): `theme.colorScheme.onSurface` (active) / `surfaceContainerHighest` (inactive)
- Section labels: uppercase, `labelSmall` with w600, `onSurfaceVariant` color
- Use Material 3 theme tokens everywhere — never hardcoded hex values
- Tap targets: minimum 48dp height with `HitTestBehavior.opaque`
- WCAG AA contrast: 4.5:1 for text, 3:1 for UI graphics

## Dependencies

- `freezed` / `freezed_annotation` — immutable models, sealed classes, copyWith
- `build_runner` (dev) — code generation
- `provider` — dependency injection
- `flutter_colorpicker` — color wheel
- `flutter_lucide` — scene icons
- `shared_preferences` — bulb persistence
- `network_info_plus` — subnet auto-detection
