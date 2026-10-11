# HASSANY Swift Native V3 — integration status

- GitHub Actions [native framework build run](https://github.com/husszzzz/hassanyIPA1/actions/runs/38135894359): success.
- Native UIKit welcome is implemented in Swift: `integration/HassanyWelcome.swift`.
- Objective-C startup adapter: `integration/HassanySwiftBootstrap.m`. Existing old welcome suppression is retained in the adapter.
- Unsigned IPA created from the authorized XO baseline, with the new `HassanyGate.framework` and branded logo.
- Local ZIP integrity check: passed; native framework and load command verified.
- **The V3 IPA has not been tested on an iPhone.** The old welcome may need another integration adjustment if seen.
- License UI calls `/api/activate` only when a valid `HassanyAPIBaseURL` HTTPS string is configured in the app's Info.plist; no live URL is configured yet.
- License backend source is in `backend/`, with GitHub Actions tests passing. The admin dashboard is not yet publicly hosted. Render declined a new Postgres resource without a payment method.
- GitHub Pages is static hosting and cannot itself run the Flask API or PostgreSQL.
- Do not upload any copyrighted game IPA, Apple signing certificate, passwords, or tokens to this public repository.

Current goal: test V3 UI on device; deploy secure license API; set app URL, rebuild and test activation end to end.
