# XO vs NEXTDEV IPA comparison

Inspection of the two user-provided unsigned/modified 8 Ball Pool IPAs. This is a **static file-level comparison**, not a runtime test.

## Finding

Both archives contain **3,179 entries**. Their **main game executable is byte-identical** (78,684,080 bytes; same SHA-256) and the **libloader** binary is also byte-identical (27,379,256 bytes).

Only **two paths common to both archives differ in file content**:
- `Payload/pool.app/Frameworks/navyx0.framework/navyx0` (556,016 bytes in both builds)
- `Payload/pool.app/Info.plist` (display name XO vs NEXTDEV, and other metadata differences)

**NEXTDEV-only** entries:
- `Payload/pool.app/Frameworks/NextdevGate.framework/NextdevGate` (68,065 bytes)
- `Payload/pool.app/Frameworks/NextdevGate.framework/Info.plist`
- `Payload/pool.app/NextdevWelcomeLogo.png`

**XO-only** entries:
- `Payload/pool.app/Frameworks/navyx0.framework/_CodeSignature/CodeResources`
- `Payload/pool.app/_CodeSignature/CodeResources`
- `Payload/pool.app/SignedByEsign`

Both `navyx0` binaries have the `RWWelcomeController` and `WelcomeManager` strings. The NEXTDEV variant additionally includes `NEXTDEV` and a Telegram URL; the XO variant does not contain `NEXTDEV`.

Both IPAs report app version **56.29.2** and bundle identifier `com.miniclip.8ballpoolmult`.

## Interpretation

Evidence is consistent with NEXTDEV being a derivative of XO where a welcome/activation-related native framework, asset, and `navyx0` modifications were added. This does **not** establish how the new framework is loaded or whether simply removing it would work.

## Engineering implications

- Use XO as a reference baseline and avoid blindly deleting dependencies.
- Do not assume the stock game binary invokes a newly created welcome framework.
- A drop-in native overlay requires an explicit app integration/entry point and iOS test.
- Neither a deployed license backend nor a verified game-integrated IPA has been built.
- Do not commit proprietary IPA binaries, signing data, credentials or production license secrets into this public repository.
