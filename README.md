# Lampo

Control your WiZ smart bulbs straight from your phone — no cloud account, no
hub app phoning home. Your lights, your LAN.

The official WiZ app routes through their cloud. Lampo talks directly to the
bulbs over your home WiFi: faster, and it works even when the internet
doesn't.

## Install

Grab the latest APK from [releases](https://github.com/udit-001/lampo/releases)
and install it on your Android phone:

1. Download `app-release.apk` from the latest release
2. Open it on your phone (allow "install from unknown sources" if asked)
3. Connect to the same WiFi as your bulbs

**[All releases](https://github.com/udit-001/lampo/releases)**

## What it does

- **Finds your bulbs** — scans your network automatically, no pairing
- **Live color swatches** — every bulb shows its actual color on the home screen
- **Three control modes** — warm-to-cool white (2200K–6500K), a full RGB wheel, and WiZ scenes
- **Works offline** — bulbs offline? You still see their last state and "last seen 2h ago"
- **Instant UI** — changes reflect immediately, even before the bulb confirms
- **Tells you when a command failed** — amber badge, no silent failures

## Building and contributing

Lampo is a Flutter app (MVVM, hand-written test fakes). Setup, architecture,
and the design system live in [AGENTS.md](AGENTS.md).
