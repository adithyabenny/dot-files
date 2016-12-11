# list of aliases

alias ..='cd ..'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'
alias ..5='cd ../../../../..'

alias cp='cp -v'
alias dig='dig +short'
alias l='ls -CF'
alias la='ls -A'
alias ld='ls -d */ 2>/dev/null'
alias lh='ls -d .??* 2>/dev/null'
alias ll='ls -alFh'
alias mv='mv -v'
alias mkdir='mkdir -pv'
if [[ "$OSTYPE" == "linux-gnu" ]] ; then
  alias osv='cat /etc/*-release | sort | uniq'
  alias port='sudo netstat -tulpn'
elif [[ "$OSTYPE" == "darwin"* ]] ; then
  alias port='sudo lsof -nP -itcp -stcp:listen | grep --color=none v4'
fi
alias pls='sudo $(history -p \!\!)'
alias rm='rm -v'
alias sudo='sudo '
alias service='sudo service'
alias watch='watch --color '

if hash systemctl 2>/dev/null ; then
  alias scl='sudo systemctl'
  source /usr/share/bash-completion/completions/systemctl
  complete -F _systemctl scl
fi

alias pb="SERVER='https://pb.mittu.me' haste"
alias x=extract


# list of functions

# extract the contents of an archive
extract() {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2) tar vxjf "$1" ;;
      *.tar.gz) tar vxzf "$1" ;;
      *.tar.Z) tar vxzf "$1" ;;
      *.bz2) bunzip2 -v "$1" ;;
      *.rar) 7za x "$1" ;;
      *.gz) gunzip -v "$1" ;;
      *.jar) 7za x "$1" ;;
      *.tar) tar vxf "$1" ;;
      *.tar.xz) tar vxf "$1" ;;
      *.tbz2) tar vxjf "$1" ;;
      *.tgz) tar vxzf "$1" ;;
      *.zip) 7za x "$1" ;;
      *.Z) uncompress -v "$1" ;;
      *.7z) 7za x "$1" ;;
      *) echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a file"
  fi
}

# find file by name
ff() {
  find . -type f -iname '*'"$*"'*' -ls 2>/dev/null
}

# upload contents to pastebin
haste() {
  if [ -z "$SERVER" ] ; then
    url="http://hastebin.com"
  else
    url="$SERVER"
  fi
  content=$(cat)
  response=$(curl -XPOST -s -d "$content" "$url/documents")
  awk -F '"' -v url="$url/raw/" '{print url $4}' <<< $response
}

# list all interfaces and their IPs
ipp() {
  interfaces=$(ifconfig | grep mtu | awk '{print $1}' | cut -d':' -f1 | grep -v 'lo')
  for interface in $interfaces ; do
    ip=$(ifconfig $interface | grep "inet[^6]" | awk '{print $2}' | cut -d':' -f2)
    if [ -n "$ip" ] ; then
      echo -e "$interface\t$ip"
    fi
  done
}

# show public IP
pipp() {
  curl -s icanhazip.com
}
