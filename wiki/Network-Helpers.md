# Network Helpers

## `netinfo2`

Usage:

```bash
netinfo2
netinfo2 localhost
netinfo2 example.com
```

Input:

- Optional hostname for DNS test.
- Default hostname: `example.com`.

Environment variables:

| Variable | Value | Effect |
|---|---|---|
| `NETINFO2_SKIP_PUBLIC_IP` | `1` | skip external public IP lookup |
| `NETINFO2_NO_PUBLIC_IP` | `1` | skip external public IP lookup |

CI example:

```bash
NETINFO2_SKIP_PUBLIC_IP=1 netinfo2 localhost
```

`netinfo2` uses fallbacks so it can work on many distros:

| Section | Preferred tools / fallbacks |
|---|---|
| interfaces | `ip`, `ifconfig` |
| routes | `ip`, `route`, `netstat` |
| DNS servers | `resolvectl`, `systemd-resolve`, `nmcli`, `/etc/resolv.conf`, `scutil` |
| DNS lookup | `doggo`, `dig`, `drill`, `host`, `nslookup`, `getent` |
| public IP | `curl`, `wget` |
| listening ports | `ss`, `netstat`, `lsof` |
| firewall | `firewall-cmd`, `ufw`, `nft`, `iptables` |

## Other network commands

| Command | Input | Meaning |
|---|---|---|
| `myip` | none | local interface/IP summary |
| `publicip` | none | external IP lookup over HTTPS |
| `ports` | none | listening ports |
| `openports` | none | same as `ports` |
| `routes` | none | route table/default route info |
| `dnsservers` | none | DNS servers |
