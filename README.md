# AntiSleep

A lightweight macOS menu bar app that keeps your Mac awake. No main window — it
lives entirely in the status bar with a physical-light-switch toggle.

## Requirements

- macOS 13.0+
- Xcode 15+ (built and verified with Xcode 26.5)

## Features

- **Menu bar only** (`LSUIElement`) — light/dark adaptive template icon.
- **Light-switch toggle** to flip Anti-Sleep ON/OFF.
- **Core logic** via `IOPMAssertionCreateWithName` (`PreventUserIdleSystemSleep`).
- **First-launch onboarding** requesting notification permission.
- **Settings window** showing permission status with a re-authorize button.
- **Launch at Login** via `SMAppService`, toggleable from Settings and Onboarding.
- **Liquid Glass UI** — translucent `.ultraThinMaterial` cards and borderless,
  transparent windows for a premium, light/dark-adaptive look.

## Build & Run

```sh
make build     # compile Release
make run       # build and launch
open AntiSleep.xcodeproj   # or just open in Xcode
```

## Package a .dmg

```sh
make dmg       # outputs build/AntiSleep.dmg
```

The DMG step copies the built `.app` and runs `scripts/make_dmg.sh`, which
creates a compressed image with a drag-to-`/Applications` symlink.

## Project layout

```
AntiSleep.xcodeproj/        Xcode project (objectVersion 77, synchronized group)
AntiSleep/                  Swift sources, Info.plist, entitlements, assets
scripts/make_dmg.sh         hdiutil-based DMG packaging
Makefile                    build / run / dmg / clean
```

## Distribution notes

The project builds unsigned for local development (`CODE_SIGNING_ALLOWED=NO`
in the Makefile). For public distribution, set a Developer ID signing identity
and notarize the app before running `make dmg`.
