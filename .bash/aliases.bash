# list of aliases

alias ..='cd ..'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'
alias ..5='cd ../../../../..'

alias cp='cp --verbose'
alias dig='dig +short'
alias l='ls -CF'
alias la='ls -A'
alias ld='ls -d */ 2>/dev/null'
alias lh='ls -d .??* 2>/dev/null'
alias ll='ls -alFh'
alias mv='mv --verbose'
alias mkdir='mkdir -pv'
alias osv='cat /etc/*-release | sort | uniq'
alias port='sudo netstat -tulpn'
alias please='sudo $(history -p \!\!)'
alias rm='rm --verbose'
alias sudo='sudo '
alias service='sudo service'
alias systemctl='sudo systemctl'

if [ -f /etc/centos-release ] ; then
  DISTRO='centos'
elif [ -f /etc/lsb-release ] ; then
  DISTRO='ubuntu'
fi
case "$DISTRO" in
  centos)
    if hash ack-grep 2>/dev/null ; then
      alias afind='ack-grep -i --nojs --nocss'
    fi
    ;;
  ubuntu)
    if hash ack 2>/dev/null ; then
      alias afind='ack -i --nojs --nocss'
    fi
    ;;
esac

if hash colordiff 2>/dev/null ; then
  alias diff='colordiff'
fi
if hash geoiplookup 2>/dev/null ; then
  alias geoip='geoiplookup -f /usr/share/GeoIP/GeoIPCity.dat '
fi
alias P="python -mjson.tool"
alias pb="curl -s -F 'paste=<-' http://pb.mittu.me/"
alias x=extract


# list of functions

ctc() {
  if hash pygmentize 2>/dev/null ; then
    prog='pygmentize -g'
  else
    prog='cat'
  fi
  sed -e 's/#.*$//' -e '/^$/d' $1 | $prog
}

extract() {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2) tar vxjf "$1" ;;
      *.tar.gz) tar vxzf "$1" ;;
      *.tar.Z) tar vxzf "$1" ;;
      *.bz2) bunzip2 -v "$1" ;;
      *.rar) 7z x "$1" ;;
      *.gz) gunzip -v "$1" ;;
      *.jar) 7z x "$1" ;;
      *.tar) tar vxf "$1" ;;
      *.tar.xz) tar vxf "$1" ;;
      *.tbz2) tar vxjf "$1" ;;
      *.tgz) tar vxzf "$1" ;;
      *.zip) 7z x "$1" ;;
      *.Z) uncompress -v "$1" ;;
      *.7z) 7z x "$1" ;;
      *) echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a file"
  fi
}

ff() {
  find . -type f -iname '*'"$*"'*' -ls 2>/dev/null
}

ipp() {
  netstat -i | tail -n+3 | awk '{print $1'} | grep -v "lo" | while read interface ; do
    ip=$(ifconfig $interface | grep "inet[^6]" | awk '{print $2}' | cut -d':' -f2)
    if [ -n "$ip" ] ; then
      echo -e "$interface\t$ip"
    fi
  done
}

pipp() {
  curl icanhazip.com 2>/dev/null
}

share() {
  temp="/tmp/myshare-$RANDOM"
  mkdir -p $temp &>/dev/null
  for f in "$@" ; do
    path=$(realpath "$f")
    name=$(basename "$f")
    ln -s "$path" "$temp/$name"
  done
  cd $temp

  port=8000
  result=$(netstat -tulpn 2>/dev/null | grep "$port")
  while [ -n "$result" ] ; do
    if [ -n "$result" ] ; then
      ((port++))
    fi
      result=$(netstat -tulpn 2>/dev/null | grep "$port")
  done

  netstat -i | tail -n+3 | awk '{print $1}' | grep -v "lo" >$temp/interfaces && echo lo >>$temp/interfaces
  cat interfaces | while read interface ; do
    ip=$(ifconfig $interface | grep "inet[^6]" | awk '{print $2}' | cut -c 6-)
    if [ -n "$ip" ] ; then
      echo "Starting server at http://$ip:$port/ ..."
      break
    fi
  done
  rm interfaces &>/dev/null

  python2 -m SimpleHTTPServer $port 2>/dev/null

  cd - &>/dev/null
  rm -rf $temp &>/dev/null
}
