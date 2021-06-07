#add to .bashrc

#===============================#
#	Alias
#===============================#

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

#===============================#
#	Functions		            #
#===============================#

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

# Move 'up' so many directories instead of using several cd ../../, etc.
up() { cd $(eval printf '../'%.0s {1..$1}) && pwd; }

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
