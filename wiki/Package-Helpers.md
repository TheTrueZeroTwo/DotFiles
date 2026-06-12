# Package Helpers

The `pac*` helpers provide a single command vocabulary across Linux package managers.

Run the menu:

```bash
pac
```

Show detected package manager:

```bash
pacpm
```

## Supported package managers

- `apt` / `apt-get`
- `dnf`
- `yum`
- `pacman`, with `yay` preferred for Arch installs/upgrades when available
- `zypper`
- `apk`
- `brew`

## Commands

| Command | Input | Meaning |
|---|---|---|
| `paci` | `<package> [...]` | install one or more packages |
| `pacu` | none | upgrade all packages to newest available version |
| `pacr` | `<package> [...]` | remove/uninstall packages |
| `pacs` | `<keyword> [...]` | search packages |
| `pacinfo` | `<package> [...]` | show package info |
| `pacinstalled` | `<package> [...]` | check whether a package is installed |
| `paca` | none | list installed packages |
| `paclo` | none | list orphaned or no-longer-needed packages where supported |
| `pacdnc` | none | clean package cache / no-longer-needed cache files |
| `pacfiles` | `<package> [...]` | list files installed by a package |
| `pacwhoownsit` | `<file/path> [...]` | show which package owns a file |
| `paclcf` | `<package> [...]` | list config files owned by package where supported |
| `pacexpl` | `<package> [...]` | mark package as explicitly/user installed |
| `pacimpl` | `<package> [...]` | mark package as automatically/dependency installed |

## Synonyms

| Name | Same as |
|---|---|
| `pacup` | `pacu` |
| `pacsearch` | `pacs` |
| `pacown` | `pacwhoownsit` |
| `paccache` | `pacdnc` |
| `pacorphans` | `paclo` |

## Examples

```bash
paci curl git htop
pacs openssh
pacinfo bash
pacinstalled git
pacfiles bash
pacwhoownsit /usr/bin/bash
pacdnc
```

## Notes

Not every package manager supports every feature. Unsupported commands print a clear message instead of failing silently.
