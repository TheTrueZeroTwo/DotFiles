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

#===============================#
# Package manager wrapper helpers
#===============================#
# pac          - show this package helper menu
# pacpm        - show detected package manager
# paci         - install one or more packages
# pacu         - upgrade all packages to their newest version
# pacr         - uninstall one or more packages
# pacs         - search for a package using one or more keywords
# pacinfo      - show information about a package
# pacinstalled - show if a package is installed
# paca         - list all installed packages
# paclo        - list orphaned/no-longer-needed packages, where supported
# pacdnc       - delete package cache files no longer needed
# pacfiles     - list all files installed by a given package
# pacwhoownsit - show what package owns a given file
# paclcf       - list config files installed by a given package, where supported
# pacexpl      - mark one or more packages as explicitly/user installed
# pacimpl      - mark one or more packages as automatically/dependency installed

_pac_detect_pm() {
  if have apt-get; then
    echo apt
  elif have dnf; then
    echo dnf
  elif have yum; then
    echo yum
  elif have pacman; then
    echo pacman
  elif have zypper; then
    echo zypper
  elif have apk; then
    echo apk
  elif have brew; then
    echo brew
  else
    echo unsupported
  fi
}

_pac_as_root() {
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    "$@"
  elif have sudo; then
    sudo "$@"
  else
    printf 'This command needs root. Install sudo or run as root:' >&2
    printf ' %q' "$@" >&2
    printf '\n' >&2
    return 1
  fi
}

_pac_need_args() {
  local name="$1"
  shift
  if [ "$#" -eq 0 ]; then
    echo "usage: $name <package-or-file> [...]" >&2
    return 2
  fi
}

_pac_unsupported() {
  local command_name="$1"
  local pm
  pm="$(_pac_detect_pm)"
  echo "$command_name is not supported for detected package manager: $pm" >&2
  return 1
}

pacpm() {
  _pac_detect_pm
}

pac() {
  cat <<'PAC_HELP'
Package helper commands:

  pac          - show this menu
  pacpm        - show detected package manager
  paci         - install one or more packages
  pacu         - upgrade all packages to their newest version
  pacr         - uninstall one or more packages
  pacs         - search for a package using one or more keywords
  pacinfo      - show information about a package
  pacinstalled - show if a package is installed
  paca         - list all installed packages
  paclo        - list orphaned/no-longer-needed packages, where supported
  pacdnc       - delete package cache files no longer needed
  pacfiles     - list all files installed by a given package
  pacwhoownsit - show what package owns a given file
  paclcf       - list config files installed by a given package, where supported
  pacexpl      - mark one or more packages as explicitly/user installed
  pacimpl      - mark one or more packages as automatically/dependency installed

Supported managers:

  apt, dnf, yum, pacman/yay, zypper, apk, brew

Examples:

  paci htop curl
  pacs openssh
  pacinfo bash
  pacinstalled git
  pacfiles bash
  pacwhoownsit /usr/bin/bash
PAC_HELP
}

paci() {
  _pac_need_args paci "$@" || return
  case "$(_pac_detect_pm)" in
    apt) _pac_as_root apt-get install "$@" ;;
    dnf) _pac_as_root dnf install "$@" ;;
    yum) _pac_as_root yum install "$@" ;;
    pacman)
      if have yay; then
        yay -S "$@"
      else
        _pac_as_root pacman -S --needed "$@"
      fi
      ;;
    zypper) _pac_as_root zypper install "$@" ;;
    apk) _pac_as_root apk add "$@" ;;
    brew) brew install "$@" ;;
    *) _pac_unsupported paci ;;
  esac
}

pacu() {
  case "$(_pac_detect_pm)" in
    apt)
      _pac_as_root apt-get update && _pac_as_root apt-get full-upgrade -y && _pac_as_root apt-get autoremove -y
      ;;
    dnf) _pac_as_root dnf upgrade --refresh -y && _pac_as_root dnf autoremove -y ;;
    yum) _pac_as_root yum update -y ;;
    pacman)
      if have yay; then
        yay -Syu
      else
        _pac_as_root pacman -Syu
      fi
      ;;
    zypper) _pac_as_root zypper refresh && _pac_as_root zypper update -y ;;
    apk) _pac_as_root apk update && _pac_as_root apk upgrade ;;
    brew) brew update && brew upgrade && brew cleanup ;;
    *) _pac_unsupported pacu ;;
  esac
}

pacr() {
  _pac_need_args pacr "$@" || return
  case "$(_pac_detect_pm)" in
    apt) _pac_as_root apt-get remove "$@" ;;
    dnf) _pac_as_root dnf remove "$@" ;;
    yum) _pac_as_root yum remove "$@" ;;
    pacman) _pac_as_root pacman -Rns "$@" ;;
    zypper) _pac_as_root zypper remove "$@" ;;
    apk) _pac_as_root apk del "$@" ;;
    brew) brew uninstall "$@" ;;
    *) _pac_unsupported pacr ;;
  esac
}

pacs() {
  _pac_need_args pacs "$@" || return
  case "$(_pac_detect_pm)" in
    apt)
      if have apt-cache; then
        apt-cache search "$@"
      else
        apt search "$@"
      fi
      ;;
    dnf) dnf search "$@" ;;
    yum) yum search "$@" ;;
    pacman) pacman -Ss "$@" ;;
    zypper) zypper search "$@" ;;
    apk) apk search "$@" ;;
    brew) brew search "$@" ;;
    *) _pac_unsupported pacs ;;
  esac
}

pacinfo() {
  _pac_need_args pacinfo "$@" || return
  case "$(_pac_detect_pm)" in
    apt)
      if have apt-cache; then
        apt-cache show "$@"
      else
        apt show "$@"
      fi
      ;;
    dnf) dnf info "$@" ;;
    yum) yum info "$@" ;;
    pacman) pacman -Si "$@" ;;
    zypper) zypper info "$@" ;;
    apk) apk info -a "$@" ;;
    brew) brew info "$@" ;;
    *) _pac_unsupported pacinfo ;;
  esac
}

pacinstalled() {
  _pac_need_args pacinstalled "$@" || return
  case "$(_pac_detect_pm)" in
    apt)
      if have dpkg-query; then
        dpkg-query -W -f='${binary:Package}\t${Version}\t${Status}\n' "$@"
      elif have apt-cache; then
        apt-cache policy "$@"
      else
        apt list --installed "$@"
      fi
      ;;
    dnf) dnf list installed "$@" ;;
    yum) yum list installed "$@" ;;
    pacman) pacman -Q "$@" ;;
    zypper) zypper search --installed-only "$@" ;;
    apk) apk info -e "$@" ;;
    brew) brew list --versions "$@" ;;
    *) _pac_unsupported pacinstalled ;;
  esac
}

paca() {
  case "$(_pac_detect_pm)" in
    apt)
      if have dpkg-query; then
        dpkg-query -W -f='${binary:Package}\t${Version}\n'
      else
        apt list --installed
      fi
      ;;
    dnf|yum) rpm -qa | sort ;;
    pacman) pacman -Q ;;
    zypper) zypper search --installed-only ;;
    apk) apk info ;;
    brew) brew list --versions ;;
    *) _pac_unsupported paca ;;
  esac
}

paclo() {
  case "$(_pac_detect_pm)" in
    apt)
      if have deborphan; then
        deborphan
      else
        apt-get -s autoremove | awk '/^Remv /{print $2}'
      fi
      ;;
    dnf) dnf repoquery --unneeded 2>/dev/null || dnf autoremove --assumeno ;;
    yum)
      if have package-cleanup; then
        package-cleanup --leaves
      else
        yum autoremove --assumeno
      fi
      ;;
    pacman) pacman -Qdt ;;
    zypper) zypper packages --orphaned ;;
    apk) _pac_unsupported paclo ;;
    brew) brew leaves ;;
    *) _pac_unsupported paclo ;;
  esac
}

pacdnc() {
  case "$(_pac_detect_pm)" in
    apt) _pac_as_root apt-get autoclean && _pac_as_root apt-get autoremove -y ;;
    dnf) _pac_as_root dnf clean packages ;;
    yum) _pac_as_root yum clean packages ;;
    pacman) _pac_as_root pacman -Sc ;;
    zypper) _pac_as_root zypper clean ;;
    apk) _pac_as_root apk cache clean ;;
    brew) brew cleanup ;;
    *) _pac_unsupported pacdnc ;;
  esac
}

pacfiles() {
  _pac_need_args pacfiles "$@" || return
  case "$(_pac_detect_pm)" in
    apt)
      if have dpkg; then
        dpkg -L "$@"
      else
        _pac_unsupported pacfiles
      fi
      ;;
    dnf|yum|zypper) rpm -ql "$@" ;;
    pacman) pacman -Ql "$@" ;;
    apk) apk info -L "$@" ;;
    brew) brew list "$@" ;;
    *) _pac_unsupported pacfiles ;;
  esac
}

pacwhoownsit() {
  _pac_need_args pacwhoownsit "$@" || return
  case "$(_pac_detect_pm)" in
    apt)
      if have dpkg; then
        dpkg -S "$@"
      else
        _pac_unsupported pacwhoownsit
      fi
      ;;
    dnf|yum|zypper) rpm -qf "$@" ;;
    pacman) pacman -Qo "$@" ;;
    apk) apk info -W "$@" ;;
    brew) brew which-formula "$@" ;;
    *) _pac_unsupported pacwhoownsit ;;
  esac
}

paclcf() {
  _pac_need_args paclcf "$@" || return
  case "$(_pac_detect_pm)" in
    apt)
      if have dpkg-query; then
        dpkg-query -W -f='${Conffiles}\n' "$@"
      else
        _pac_unsupported paclcf
      fi
      ;;
    dnf|yum|zypper) rpm -qc "$@" ;;
    pacman)
      pacman -Qii "$@" | awk '
        /^Name[[:space:]]*:/ {pkg=$3}
        /^BACKUP/ {show=1; next}
        show && NF {print pkg " " $0}
      '
      ;;
    apk|brew) _pac_unsupported paclcf ;;
    *) _pac_unsupported paclcf ;;
  esac
}

pacexpl() {
  _pac_need_args pacexpl "$@" || return
  case "$(_pac_detect_pm)" in
    apt) _pac_as_root apt-mark manual "$@" ;;
    dnf) _pac_as_root dnf mark install "$@" ;;
    yum) _pac_unsupported pacexpl ;;
    pacman) _pac_as_root pacman -D --asexplicit "$@" ;;
    zypper) _pac_unsupported pacexpl ;;
    apk) _pac_as_root apk add "$@" ;;
    brew) _pac_unsupported pacexpl ;;
    *) _pac_unsupported pacexpl ;;
  esac
}

pacimpl() {
  _pac_need_args pacimpl "$@" || return
  case "$(_pac_detect_pm)" in
    apt) _pac_as_root apt-mark auto "$@" ;;
    dnf) _pac_as_root dnf mark remove "$@" ;;
    yum) _pac_unsupported pacimpl ;;
    pacman) _pac_as_root pacman -D --asdeps "$@" ;;
    zypper) _pac_unsupported pacimpl ;;
    apk|brew) _pac_unsupported pacimpl ;;
    *) _pac_unsupported pacimpl ;;
  esac
}

# Friendly synonyms for the package wrapper.
pacup() { pacu "$@"; }
pacsearch() { pacs "$@"; }
pacown() { pacwhoownsit "$@"; }
paccache() { pacdnc "$@"; }
pacorphans() { paclo "$@"; }
