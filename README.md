<div align="center">

# ☕ AntiSleep

**A warm, Claude-inspired menu bar app that keeps your Mac awake.**

No main window. No dock icon. Just a quiet light switch in your status bar.

</div>

---

## Overview

AntiSleep is a lightweight macOS utility that prevents your Mac from going to
sleep while you need it awake — downloads, presentations, long builds, reading.
It lives entirely in the menu bar with a tactile light-switch toggle and a warm,
Claude-inspired theme (cream palette, serif headings, terracotta accent).

## Features

- **🔌 Launch at Login** — opt in via `SMAppService`; AntiSleep is ready the
  moment you log in, toggleable from Settings and Onboarding.
- **🪶 No-Jitter UI** — the menu bar popover stays rock-steady when toggling
  ON/OFF; no flicker, no resize jump, no layout shift.
- **🛡️ Safe Assertions** — wake is held through the official
  `IOPMAssertionCreateWithName` API (`PreventUserIdleSystemSleep`) and always
  released cleanly, so sleep is never blocked longer than intended.
- **🌗 Warm Claude-inspired theme** — adaptive light/dark with a cozy warm-dark
  mode, soft corners, and a template menu bar icon.
- **👋 First-launch onboarding** with a clear notification-permission request.
- **⚙️ Settings window** showing live permission status and a re-authorize button.

## Installation

**Option A — DMG (recommended)**

1. Download **`AntiSleep.dmg`** from the
   [latest release](https://github.com/galilei13/dont-sleep-project/releases/latest).
2. Open the DMG and **drag `AntiSleep.app` into `Applications`**.
3. Launch AntiSleep. Look for the light-switch icon in your menu bar.

> The app is unsigned. On first launch, right-click the app and choose **Open**
> (or allow it under **System Settings → Privacy & Security**).

**Option B — Homebrew (personal tap)**

```sh
brew tap galilei13/antisleep https://github.com/galilei13/dont-sleep-project
brew install --cask antisleep
```

## Requirements

- macOS 13.0+
- Xcode 15+ (to build from source)

## Build from Source

```sh
make build     # compile Release
make run       # build and launch
make dmg       # package build/AntiSleep.dmg
```

`make dmg` copies the built `.app` and runs `scripts/make_dmg.sh`, producing a
compressed disk image with a drag-to-`/Applications` symlink.

## Project Layout

```
AntiSleep.xcodeproj/        Xcode project
AntiSleep/                  Swift sources, Info.plist, entitlements, assets
scripts/make_dmg.sh         hdiutil-based DMG packaging
Makefile                    build / run / dmg / clean
```

## License

Released under the [MIT License](LICENSE).

## 💛 Support & Donation

If this app helps keep your Mac awake, consider supporting the project! Every
contribution helps fund continued development and is genuinely appreciated.

| Network | Address |
| --- | --- |
| **TRON** (TRC-20) | `TWmXwZ8dDVrJ8uH6Q5C3TTdsW2G5iWjg5E` |
| **Ethereum** (ERC-20) | `0x75D68d3e7c151Fe38B3E17abEC7F57948FC2D4AF` |
| **Polygon** | `0x75D68d3e7c151Fe38B3E17abEC7F57948FC2D4AF` |

> Please double-check the network before sending — crypto transfers are
> irreversible. Thank you for your support! 🙏
