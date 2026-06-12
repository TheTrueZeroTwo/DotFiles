# shellcheck shell=bash
# Interactive shell functions

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

ex() {
  extract "$@"
}

publicip() {
  if have curl; then
    curl -fsSL https://ifconfig.me && printf '\n'
  elif have wget; then
    wget -qO- https://ifconfig.me && printf '\n'
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

dns_servers() {
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

query_dns() {
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

netinfo() {
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
  publicip 2>/dev/null || echo "Unavailable"

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
#	Functions		            #
#===============================#

# paci         - install one or more packages
# pacu         - upgrade all packages to their newest version
# pacr         - uninstall one or more packages
# pacs         - search for a package using one or more keywords
# pacinfo      - show information about a package
# pacinstalled - show if a package is installed
# paca         - list all installed packages
# paclo        - list all packages which are orphaned
# pacdnc       - delete all not currently installed package files
# pacfiles        - list all files installed by a given package
# pacwhoownsit - show what package owns a given file
# paclcf       - list config files installed by a given package
# pacexpl      - mark one or more packages as explicitly installed
# pacimpl      - mark one or more packages as non explicitly installed
pac(){
	echo -e "
paci         - install one or more packages/n
pacu         - upgrade all packages to their newest version/n
pacr         - uninstall one or more packages/n
pacs         - search for a package using one or more keywords/n
pacinfo      - show information about a package/n
pacinstalled - show if a package is installed/n
paca         - list all installed packages/n
paclo        - list all packages which are orphaned/n
pacdnc       - delete all not currently installed package files/n
pacfiles     - list all files installed by a given package/n
pacwhoownsit - show what package owns a given file/n
paclcf       - list config files installed by a given package/n
pacexpl      - mark one or more packages as explicitly installed/n
pacimpl      - mark one or more packages as non explicitly installed"
}

if [ -e "/usr/bin/apt-get" ] ; then # Apt-based distros
  aptget="/usr/bin/apt-get"
  sudoaptget="sudo $aptget"
  aptcache="/usr/bin/apt-cache"
  dpkg="/usr/bin/dpkg"
  alias paci="$sudoaptget install"
  alias pacu="$sudoaptget update"
  alias pacs="$aptcache search"
  alias pacinfo="$aptcache show"
  alias pacinstalled="$aptcache policy"
  alias paca="$dpkg --get-selections"
  alias pacfiles="$dpkg -L"
elif [ -e "/usr/bin/pacman" ] ; then # Arch Linux
  pacman="/usr/bin/pacman"
  sudopacman="sudo $pacman"
  alias pacii="$pacman -S"
  alias paci="yay -S"
  alias pacu="$pacman -Syu"
  alias pacr="$sudopacman -Rns"
  alias pacs="$pacman -Ss"
  alias pacinfo="$pacman -Si"
  alias paca="$pacman -Q"
  alias paclo="$pacman -Qdt"
  alias pacdnc="$sudopacman -Scc"
  alias pacfiles="$pacman -Ql"
  alias pacexpl="$pacman -D --asexp"
  alias pacimpl="$pacman -D --asdep"
elif [ -e "/usr/bin/yum" ] ; then # RPM-based distros
  yum="/usr/bin/yum"
  sudoyum="sudo $yum"
  repoquery="/usr/bin/repoquery"
  alias paci="$sudoyum install"
  alias pacu="$sudoyum update"
  alias pacr="$sudoyum remove"
  alias pacs="$yum search"
  alias pacfiles="$repoquery -lq --installed"
  alias pacwhoownsit="$yum whatprovides"
  alias pacinfo="$yum info"
  alias paclfc="$yum -qc"
  alias paccheckforupdates="$sudoyum list updates"
elif [ -e "/usr/local/bin/brew" ] ; then # homebrew
  brew="/usr/local/bin/brew"
  alias paci="$brew install"
  alias pacu="$brew update"
  alias pacup="$brew upgrade"
  alias pacs="$brew search"
  alias pacr="$brew uninstall"
 elif [ -e "/usr/bin/dnf" ] ; then # fedora
  dnf="/usr/bin/dnf"
  sudodnf="sudo $dnf"
  repoquery="$sudodnf repoquery"
  alias paci="$sudodnf install"
  alias pacu="$sudodnf upgrade"
  alias pacr="$sudodnf remove"
  alias pacs="$sudodnf search"
  alias pacinfo="$sudodnf info"
fi

