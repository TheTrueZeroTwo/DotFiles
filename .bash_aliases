#add to .bashrc


if [ -d ${HOME}/.bashrc.d ]
then
  for file in ~/.bashrc.d/*.bashrc
  do
    source "${file}"
  done
fi

#===============================#
#	Alias
#===============================#

#allows sudo alias
alias sudo="sudo "

# Edit this .bashrc file
alias ebrc='nano ~/.bashrc'

# common variations of the ls command
alias ll="ls -l"
alias lo="ls -o"
alias lh="ls -lh"
alias la="ls -la"


# Git related
alias gs='git status'
alias gc='git commit'
alias ga='git add'
alias gd='git diff'
alias gb='git branch'
alias gl='git log'
alias gsb='git show-branch'
alias gco='git checkout'
alias gg='git grep'
alias gk='gitk --all'
alias gr='git rebase'
alias gri='git rebase --interactive'
alias gcp='git cherry-pick'
alias grm='git rm'

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Show open ports
alias openports='netstat -nape --inet'

#apt
alias apt-update="sudo apt update"
alias apt-upgrade="sudo apt upgrade -y"
alias apt-update-full="sudo apt update && sudo apt upgrade -y"
alias apt-install="sudo apt install -y"

#Generate a random strong password
alias genpasswd="strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo"

#Expand current directory structure in tree form
alias treed="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"

#List by file size in current directory
sbs() { du -b --max-depth 1 | sort -nr | perl -pe 's{([0-9]+)}{sprintf "%.1f%s", $1>=2**30? ($1/2**30, "G"):    $1>=2**20? ($1/2**20, "M"): $1>=2**10? ($1/2**10, "K"): ($1, "")}e';} 

#Show active ports
alias port='netstat -tulanp'

#Use this for when the boss comes around to look busy.
alias busy="cat /dev/urandom | hexdump -C | grep 'ca fe'" 

#This one saved by butt so many times
alias wget='wget -c'

#Copy with progress bar
alias cpv='rsync -ah --info=progress2'

#nano
alias nano='nano -wET 4'

#grep
alias grep="grep --color"

#tree like output
alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"

#ssh alias
#alias ssh="ssh -t zsh"
#alias servername="ssh username@address"
#example
alias plex="ssh plex@192.168.1.59"
# alias SERVERNAME='ssh YOURWEBSITE.com -l USERNAME -p PORTNUMBERHERE'



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

if [ -e "/usr/bin/apt-get" ] ; then # Apt-based distros (Debian, Ubuntu, etc.)
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
fi

# ex - archive extractor
# usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.xz)        tar xz $1    ;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Copy file with a progress bar
cpp()
{
	set -e
	strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
	| awk '{
	count += $NF
	if (count % 10 == 0) {
		percent = count / total_size * 100
		printf "%3d%% [", percent
		for (i=0;i<=percent;i++)
			printf "="
			printf ">"
			for (i=percent;i<100;i++)
				printf " "
				printf "]\r"
			}
		}
	END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}

# Copy and go to the directory
cpg ()
{
	if [ -d "$2" ];then
		cp $1 $2 && cd $2
	else
		cp $1 $2
	fi
}

# Move and go to the directory
mvg ()
{
	if [ -d "$2" ];then
		mv $1 $2 && cd $2
	else
		mv $1 $2
	fi
}

# Create and go to the directory
mkdirg ()
{
	mkdir -p $1
	cd $1
}

# Move 'up' so many directories instead of using several cd ../../, etc.
up() { cd $(eval printf '../'%.0s {1..$1}) && pwd; }


#show network info for multiple distros
netinfo2 ()
{
if [ -e "/usr/bin/apt-get" ] ; then # Apt-based distros (Debian, Ubuntu, etc.)
	echo "--------------- Network Information ---------------"
	/sbin/ifconfig | awk /'inet addr/ {print $2}'
	echo ""
	/sbin/ifconfig | awk /'Bcast/ {print $3}'
	echo ""
	/sbin/ifconfig | awk /'inet addr/ {print $4}'

	/sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'
	echo "---------------------------------------------------"
elif [ -e "/usr/bin/pacman" ] ; then # Arch Linux
	echo "--------------- Network Information ---------------"
	 | awk /'inet addr/ {print $2}'
	echo ""
	 | awk /'Bcast/ {print $3}'
	echo ""
	 | awk /'inet addr/ {print $4}'

	 | awk /'HWaddr/ {print $4,$5}'
	echo "---------------------------------------------------"

elif [ -e "/usr/bin/yum" ] ; then # RPM-based distros
	echo "--------------- Network Information ---------------"
	 | awk /'inet addr/ {print $2}'
	echo ""
	 | awk /'Bcast/ {print $3}'
	echo ""
	 | awk /'inet addr/ {print $4}'

	 | awk /'HWaddr/ {print $4,$5}'
	echo "---------------------------------------------------"
elif [ -e "/usr/local/bin/brew" ] ; then # homebrew
	echo "--------------- Network Information ---------------"
	 | awk /'inet addr/ {print $2}'
	echo ""
	 | awk /'Bcast/ {print $3}'
	echo ""
	 | awk /'inet addr/ {print $4}'

	 | awk /'HWaddr/ {print $4,$5}'
	echo "---------------------------------------------------"

fi
}


netinfo ()
{
	echo "--------------- Network Information ---------------"
	/sbin/ifconfig | awk /'inet addr/ {print $2}'
	echo ""
	/sbin/ifconfig | awk /'Bcast/ {print $3}'
	echo ""
	/sbin/ifconfig | awk /'inet addr/ {print $4}'

	/sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'
	echo "---------------------------------------------------"
}

# IP address lookup
alias whatismyip="whatsmyip"
function whatsmyip ()
{
	# Dumps a list of all IP addresses for every device
	# /sbin/ifconfig |grep -B1 "inet addr" |awk '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' |awk -F: '{ print $1 ": " $3 }';

	# Internal IP Lookup
	echo -n "Internal IP: " ; /sbin/ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'

	# External IP Lookup
	echo -n "External IP: " ; wget http://smart-ip.net/myip -O - -q
}

#Converting audio and video files
function 2ogg() { eyeD3 --remove-all-images "$1"; fname="${1%.*}"; sox "$1" "$fname.ogg" && rm "$1"; }
function 2wav() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.wav" && rm "$1"; }
function 2aif() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.aif" && rm "$1"; }
function 2mp3() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.mp3" && rm "$1"; }
function 2mov() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.mov" && rm "$1"; }
function 2mp4() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.mp4" && rm "$1"; }
function 2avi() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.avi" && rm "$1"; }
function 2webm() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" -c:v libvpx "$fname.webm" && rm "$1"; }
function 2h265() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" -c:v libx265 "$fname'_converted'.mp4" && rm "$1"; }
function 2flv() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.flv" && rm "$1"; }
function 2mpg() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.mpg" && rm "$1"; }

