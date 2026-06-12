# DotFiles Wiki

This wiki documents the TheTrueZeroTwo DotFiles repository hosted at:

```text
https://gitthegit.zerotwo.tech/ZeroTwo/DotFiles
```

## Pages

- [User Guide](User-Guide.md)
- [One-Line Install](One-Line-Install.md)
- [Aliases and Functions](Aliases-and-Functions.md)
- [Package Helpers](Package-Helpers.md)
- [Network Helpers](Network-Helpers.md)
- [Contributor Guide](Contributor-Guide.md)
- [Pull Request Guide](Pull-Request-Guide.md)
- [CI and Testing](CI-and-Testing.md)
- [Troubleshooting](Troubleshooting.md)

## What this repo does

The repo installs shell quality-of-life helpers, package-manager wrappers, network diagnostics, pentesting helpers, and safe shell startup blocks. The installer is idempotent and tracks state so rerunning it does not keep appending duplicate config.

## Supported systems

- Debian / Ubuntu / Kali / Parrot with `apt`
- Fedora / Nobara / RHEL-like systems with `dnf` or `yum`
- Arch / EndeavourOS / Manjaro with `pacman` and optional `yay`
- openSUSE with `zypper`
- Alpine with `apk`
- macOS/Homebrew partial support
