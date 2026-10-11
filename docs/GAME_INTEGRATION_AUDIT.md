# 8 Ball Pool IPA integration audit (2026-10-11)

Scope: structural inspection of the user-provided unsigned IPA. This file is **not committed** because the repository is public and contains proprietary third-party game data.

## Confirmed within IPA

- Main executable: `Payload/pool.app/pool`
- Existing welcome/activation framework: `Payload/pool.app/Frameworks/NextdevGate.framework/NextdevGate` (68,065 bytes)
- Additional framework containing welcome symbols: `Payload/pool.app/Frameworks/navyx0.framework/navyx0` (556,016 bytes)
- Loader framework: `Payload/pool.app/Frameworks/libloader.framework/libloader` (~27.4 MB)
- Existing welcome image: `Payload/pool.app/NextdevWelcomeLogo.png`
- `RWWelcomeController` and `WelcomeManager` appear in both the NextdevGate and navyx0 binaries; both also contain the string NEXTDEV.

## Important integration distinction

The repository's current SwiftUI application is an independent app, not a drop-in replacement for the game's compiled frameworks. Renaming or deleting the legacy libraries can break dynamic linking or runtime assumptions. Signing an IPA does not resolve missing frameworks.

## Proposed implementation stages

1. Obtain the original Xcode game integration project or minimal documented SDK API from the rights holders, when available.
2. Design a native UIKit/Swift welcome overlay as a separately compiled framework with a clearly defined integration entry point.
3. Develop the licensing service and admin dashboard; require authenticated administrator access and secure HTTPS, and do not store production secrets in GitHub.
4. Integrate the overlay through an authorized project build and test startup and dismissal on actual iOS devices.
5. Package the result as an unsigned IPA in macOS GitHub Actions, then test user signing and launch.

## Currently not complete

No game-integrated replacement framework, no functional license backend deployment, no production dashboard deployment, no validated unsigned modified game IPA.
