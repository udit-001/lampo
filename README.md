# Lampo

Local-first controller for WiZ smart bulbs over UDP (port 38899). No cloud account, no internet — just your phone and your bulbs on the same WiFi.

## Features

- **Auto-discovery** — detects your network subnet and finds WiZ bulbs via broadcast + subnet scan
- **Colored swatches** — home screen shows each bulb's actual color at a glance
- **Three control modes** — White (color temperature 2200K–6500K), Color (RGB wheel), Scene (with animated/static badges)
- **Live updates** — syncPilot push + 30s poll fallback keeps state current
- **Optimistic UI** — every action reflects instantly, even before the bulb confirms
- **Offline tracking** — offline bulbs show "last seen 2h ago" and remain tappable
- **Command-failed indicator** — amber badge when a command doesn't reach the bulb

## Tech Stack

- Flutter 3.44 / Dart 3.12
- MVVM architecture (Repository → ViewModel → View)
- Freezed for immutable models
- Provider for dependency injection
- Hand-written fakes for testing (no mockito)

## Getting Started

```bash
flutter pub get
dart run build_runner build          # generate freezed code
flutter run                           # run on connected device
```

### Build & install APK

```bash
flutter build apk --release --target-platform android-arm64
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Testing

```bash
flutter analyze                       # zero issues required
flutter test                          # all tests must pass
```

## Architecture

```
lib/
├── data/
│   ├── models/         # Bulb, BulbState, BulbCommand, BulbInfo, BulbEvent
│   ├── repositories/   # BulbRepository
│   └── services/       # WizProtocol, Discovery, BulbStore
├── domain/
│   └── models/         # WizScene, SceneCategory
└── ui/
    ├── core/           # BulbColorSwatch, PreviewBox, badges
    └── features/
        ├── home/       # HomeScreen, HomeViewModel
        └── bulb_detail/ # BulbDetailScreen, ScenePickerScreen, DeviceInfoSheet
```

See `AGENTS.md` for detailed architecture decisions, design system rules, and contributor workflow.
