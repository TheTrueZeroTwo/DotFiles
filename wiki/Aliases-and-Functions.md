# Aliases and Functions

This page documents the user-facing aliases and functions from `shell/bash_aliases`, `shell/functions.sh`, and `shell/pentesting_aliases`.

## Shell reload/edit helpers

| Name | Type | Input | What it does |
|---|---|---|---|
| `ebrc` | alias | none | opens `~/.bashrc` in `$EDITOR` or `nano` |
| `ezrc` | alias | none | opens `~/.zshrc` in `$EDITOR` or `nano` |
| `ealias` | alias | none | opens `~/.bash_aliases` |
| `reloadbash` | alias | none | sources `~/.bashrc` |
| `reloadzsh` | alias | none | sources `~/.zshrc` |

## Directory and listing helpers

| Name | Type | Input | What it does |
|---|---|---|---|
| `ls` | alias | paths accepted by `ls`/`eza` | uses `eza` or `exa` with directories first when available |
| `ll` | alias | optional path | long listing with hidden files and git info when supported |
| `la` | alias | optional path | long listing with hidden files |
| `lh` | alias | optional path | human-readable long listing |
| `mkdirp` | alias | directory path(s) | `mkdir -p` |
| `mkcd` | function | `<directory>` | create a directory and enter it |
| `dus` | alias | none | size of items in current directory, sorted |
| `dfh` | alias | none | `df -hT` |
| `freeh` | alias | none | `free -h` |
| `path` | alias | none | prints `$PATH` one entry per line |
| `sbs` | function | none | lists current directory items by size |

## Git helpers

| Name | Type | Input | What it does |
|---|---|---|---|
| `gs` | alias | none | `git status` |
| `ga` | alias | file/path args | `git add` |
| `gc` | alias | commit args | `git commit` |
| `gd` | alias | diff args | `git diff` |
| `gb` | alias | branch args | `git branch` |
| `gl` | alias | none | graph log for all branches |
| `gco` | alias | branch/commit | `git checkout` |
| `gsw` | alias | branch | `git switch` |
| `gp` | alias | remote/branch args | `git push` |
| `gpl` | alias | remote/branch args | `git pull` |
| `gf` | alias | none | `git fetch --all --prune` |
| `gr` | alias | rebase args | `git rebase` |
| `gri` | alias | rebase args | `git rebase --interactive` |

## Network helpers

| Name | Type | Input | What it does |
|---|---|---|---|
| `netinfo2` | function | optional hostname, default `example.com` | multi-distro network report |
| `myip` | function | none | local IP/interface summary |
| `publicip` | function | none | external IP via HTTPS |
| `openports` | alias/function | none | listening ports using `ss`, `netstat`, or `lsof` |
| `ports` | function | none | listening ports |
| `port` | alias | none | same as `ports` |
| `listening` | alias | none | same as `ports` |
| `routes` | alias | none | default route info |
| `dnsservers` | alias | none | DNS server list |
| `externalip` | alias | none | same as `publicip` |
| `pubip` | alias | none | same as `publicip` |

## File/archive helpers

| Name | Type | Input | What it does |
|---|---|---|---|
| `extract` | function | `<archive> [...]` | extracts tar/zip/7z/rar/gz/bz2/xz/zst formats when tools exist |
| `servehere` | function | optional port, default `8000` | starts a Python HTTP server in the current directory |
| `genpasswd` | function | optional length, default `30` | generates a random password |

## chmod safety helpers

| Name | Type | Input | What it does |
|---|---|---|---|
| `mx` | alias | file/path | `chmod a+x` |
| `chmod000r` | alias | path(s) | asks for `YES`, then recursively chmods `000` |
| `chmod644r` | alias | path(s) | asks for `YES`, then recursively chmods `644` |
| `chmod666r` | alias | path(s) | asks for `YES`, then recursively chmods `666` |
| `chmod755r` | alias | path(s) | asks for `YES`, then recursively chmods `755` |
| `chmod777r` | alias | path(s) | asks for `YES`, then recursively chmods `777` |

## Pentesting helpers

Use only on systems and networks you own or are authorized to test.

| Name | Type | Input | What it does |
|---|---|---|---|
| `nmap_initial` | function | `<target>` | `nmap -O -sC -sV`, saves to `scans/nmap/initial-*` |
| `nmap_fast` | function | `<target>` | fast top-port Nmap scan |
| `nmap_full_tcp` | function | `<target>` | full TCP port scan with faster rate |
| `nmap_udp_top` | function | `<target>` | top 100 UDP ports with sudo |
| `web_enum_basic` | function | `<url>` | runs `whatweb` and `gobuster` when installed |
| `kali_nmap_initial` | alias | `<target>` | alias for `nmap_initial` |
| `kali_nmap_fast` | alias | `<target>` | alias for `nmap_fast` |
| `kali_nmap_full_tcp` | alias | `<target>` | alias for `nmap_full_tcp` |
| `kali_nmap_udp_top` | alias | `<target>` | alias for `nmap_udp_top` |
| `pyserver` | alias | optional port | `python3 -m http.server` |
| `tun0ip` | function | none | prints the IPv4/IPv6 address field for `tun0` if present |
