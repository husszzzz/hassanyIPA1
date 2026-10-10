# Hassany IPA

A new independent iOS application. Channel: [@hassanyIPA](https://t.me/hassanyIPA). Developer: [@OM_G9](https://t.me/OM_G9).

## Status

- Native SwiftUI welcome screen: committed.
- XcodeGen project and GitHub Actions unsigned-IPA workflow: committed.
- The Actions build result is not yet verified.
- License activation screen is a **placeholder**; there is no connected activation backend, database, or live admin dashboard in this repository yet.
- This project is **not** a modified 8 Ball Pool IPA and does not integrate with that game.

## Build from an iPhone

Go to [GitHub Actions](https://github.com/husszzzz/hassanyIPA1/actions/workflows/ios-build.yml), open **Build unsigned Hassany IPA**, and inspect the most recent run. If it succeeds, download the `HassanyIPA-unsigned` artifact and sign with your own authorized signing certificate. Building without code signing does not guarantee the package will install.

## Security

Never commit admin passwords, API tokens, signing keys, license databases, or third-party game binaries to this **public** repository. For a future license backend, use a separately hosted HTTPS service and private secrets.
