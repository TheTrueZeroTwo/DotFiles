# shellcheck shell=bash
# Shared interactive shell functions for TheTrueZeroTwo DotFiles.

have() {
  command -v "$1" >/dev/null 2>&1
}

mkcd() {
  if [ "$#" -ne 1 ]; then
    echo "usage: mkcd <directory>" >&2
    return 2
  fi
  mkdir -p -- "$1" && cd -- "$1" || return
}

extract() {
  if [ "$#" -lt 1 ]; then
    echo "usage: extract <archive> [...]" >&2
    return 2
  fi

  local archive
  for archive in "$@"; do
    if [ ! -f "$archive" ]; then
      echo "extract: not a file: $archive" >&2
      continue
    fi

    case "$archive" in
      *.tar.bz2|*.tbz2) tar xjf "$archive" ;;
      *.tar.gz|*.tgz) tar xzf "$archive" ;;
      *.tar.xz|*.txz) tar xJf "$archive" ;;
      *.tar.zst|*.tzst) tar --zstd -xf "$archive" ;;
      *.tar) tar xf "$archive" ;;
      *.bz2) bunzip2 "$archive" ;;
      *.gz) gunzip "$archive" ;;
      *.xz) unxz "$archive" ;;
      *.zip) unzip "$archive" ;;
      *.7z) 7z x "$archive" ;;
      *.rar) unrar x "$archive" ;;
      *) echo "extract: unsupported archive: $archive" >&2 ;;
    esac
  done
}

publicip() {
  if have curl; then
    curl -fsSL --max-time 5 https://ifconfig.me && printf '\n'
  elif have wget; then
    wget -qO- --timeout=5 https://ifconfig.me && printf '\n'
  else
    echo "curl or wget is required" >&2
    return 1
  fi
}

myip() {
  if have ip; then
    ip -brief addr show
  elif have ifconfig; then
    ifconfig
  else
    hostname -I 2>/dev/null || hostname -i 2>/dev/null || true
  fi
}

ports() {
  if have ss; then
    ss -tulpen
  elif have netstat; then
    netstat -tulpen 2>/dev/null || netstat -tulanp
  elif have lsof; then
    lsof -nP -iTCP -sTCP:LISTEN -iUDP
  else
    echo "ss, netstat, or lsof is required" >&2
    return 1
  fi
}

openports() {
  ports "$@"
}

_dotfiles_dns_servers() {
  if have resolvectl; then
    resolvectl dns 2>/dev/null | sed 's/^/  /'
  elif have systemd-resolve; then
    systemd-resolve --status 2>/dev/null | awk '/DNS Servers:|DNS Domain:/{print "  "$0}'
  elif have nmcli; then
    nmcli dev show 2>/dev/null | awk -F': *' '/IP4.DNS|IP6.DNS/{print "  "$2}' | sort -u
  elif [ -r /etc/resolv.conf ]; then
    awk '/^nameserver/{print "  "$2}' /etc/resolv.conf
  elif have scutil; then
    scutil --dns 2>/dev/null | awk '/nameserver\[[0-9]+\]/{print "  "$3}' | sort -u
  fi
}

_dotfiles_query_dns() {
  local host="${1:-example.com}"
  if have doggo; then
    doggo "$host" A AAAA
  elif have dig; then
    dig +short "$host" A "$host" AAAA
  elif have drill; then
    drill "$host"
  elif have host; then
    host "$host"
  elif have nslookup; then
    nslookup "$host"
  else
    getent hosts "$host" 2>/dev/null || true
  fi
}

netinfo2() {
  local query_host="${1:-example.com}"

  echo "== System =="
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    echo "OS: ${PRETTY_NAME:-unknown}"
  elif have sw_vers; then
    sw_vers | sed 's/^/OS: /'
  else
    echo "OS: unknown"
  fi
  echo "Host: $(hostname 2>/dev/null || echo unknown)"
  echo "Kernel: $(uname -srmo 2>/dev/null || uname -a)"

  echo
  echo "== Interfaces =="
  if have ip; then
    ip -brief addr show
  elif have ifconfig; then
    ifconfig -a
  else
    echo "No ip/ifconfig command found"
  fi

  echo
  echo "== Default routes =="
  if have ip; then
    ip route show default 2>/dev/null || true
    ip -6 route show default 2>/dev/null || true
  elif have route; then
    route -n get default 2>/dev/null || route -n 2>/dev/null || true
  elif have netstat; then
    netstat -rn 2>/dev/null | awk '/default|^0\.0\.0\.0/{print}'
  fi

  echo
  echo "== DNS servers =="
  _dotfiles_dns_servers || true

  echo
  echo "== DNS test: ${query_host} =="
  _dotfiles_query_dns "$query_host" || true

  echo
  echo "== Public IP =="
  if [ "${NETINFO2_SKIP_PUBLIC_IP:-0}" = "1" ] || [ "${NETINFO2_NO_PUBLIC_IP:-0}" = "1" ]; then
    echo "Skipped by NETINFO2_SKIP_PUBLIC_IP"
  else
    publicip 2>/dev/null || echo "Unavailable"
  fi

  echo
  echo "== Listening ports =="
  ports 2>/dev/null | head -n 40 || echo "Unavailable"

  echo
  echo "== NetworkManager =="
  if have nmcli; then
    nmcli device status 2>/dev/null || true
  else
    echo "NetworkManager CLI not found"
  fi

  echo
  echo "== Firewall =="
  if have firewall-cmd; then
    firewall-cmd --state 2>/dev/null || true
    firewall-cmd --get-active-zones 2>/dev/null || true
  elif have ufw; then
    ufw status 2>/dev/null || true
  elif have nft; then
    nft list ruleset 2>/dev/null | sed -n '1,80p' || true
  elif have iptables; then
    iptables -S 2>/dev/null | sed -n '1,80p' || true
  else
    echo "No common firewall command found"
  fi

  return 0
}

safe_chmod_recursive() {
  if [ "$#" -lt 2 ]; then
    echo "usage: safe_chmod_recursive <mode> <path> [...]" >&2
    return 2
  fi

  local mode="$1"
  shift
  echo "About to run: chmod -R $mode $*"
  printf 'Type YES to continue: '
  local answer
  read -r answer
  [ "$answer" = "YES" ] || return 1
  chmod -R "$mode" "$@"
}
