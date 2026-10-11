# XO + HassanyGate integration test — 2026-10-11

Status: **EXPERIMENTAL, UNSIGNED, NOT DEVICE-TESTED**. The assembled IPA is not uploaded to this PUBLIC repository because it contains third-party game data.

## Build actually completed

- The native Objective-C UIKit framework is built in [successful macOS Actions run #38131151611](https://github.com/husszzzz/hassanyIPA1/actions/runs/38131151611).
- The compiled framework was added at `Payload/pool.app/Frameworks/HassanyGate.framework/HassanyGate`.
- A Mach-O `LC_LOAD_DYLIB` was added to the existing XO `navyx0.framework/navyx0` binary, referencing `@executable_path/Frameworks/HassanyGate.framework/HassanyGate`.
- `HassanyWelcomeLogo.png` added to application resources from the user-provided Hassany IPA logo.
- Display name set to `8 Ball Pool HASSANY (Test)`.
- Original main game executable `pool` is byte-identical to XO input.
- Built archive tested by Python `zipfile.testzip()`: clean.
- Framework and load command verified with LLVM object tools.
- Legacy ESign metadata and old `_CodeSignature/CodeResources` files omitted in the unsigned output; user must resign entire package in ESign.

## Native UX

- HASSANY IPA welcome overlay (UIKit, not HTML).
- Telegram channel `@hassanyIPA` and developer `@OM_G9`.
- Scrollable layout for landscape gaming orientations.
- Manual `متابعة إلى اللعبة` button to dismiss overlay.
- Auto-presentation scheduled on UIApplicationDidBecomeActive when foreground root controller is available.

## Important gaps

1. No real iPhone install or gameplay launch test has been run. A successful Mach-O patch and archive verification **do not guarantee the app opens or the overlay appears**.
2. License code field is UI-only and explicitly reports that the backend is not connected. There is **no deployed admin dashboard or functional activation database** in the test IPA.
3. Game compatibility, signing, OS requirements, and any previous third-party modifications require on-device verification.
4. Do not treat the test IPA as a complete production version. Do not publish proprietary game packages, certificates, or server passwords in this public repo.

## Immediate test

Use a certificate you are authorized to use, sign the unsigned test IPA via ESign, and attempt to launch the game on an iPhone. Report whether it (a) launches, (b) shows the Hassany overlay, and (c) returns to the game when tapping Continue. Use those facts to iterate before implementing a live licensing backend.
