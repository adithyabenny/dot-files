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

# upload file to Dropbox and share the link
# requires executable from https://github.com/andreafabrizi/Dropbox-Uploader
# echo "export DROPBOX_SCRIPT='<location-of-dropbox_uploader.sh>'" >>~/.bash/private.bash
dropbox() {
  for file in "$@" ; do
    $DROPBOX_SCRIPT -q upload "$file" /
    if [ $? -ne 0 ] ; then
      echo "Upload failed.."
      return
    fi
    response=$($DROPBOX_SCRIPT -q share "$file")
    if [ $? -ne 0 ] ; then
      echo "Sharing failed.."
      return
    fi
    url="${response::-5}"
    echo "$url"
    if [[ "$OSTYPE" == "darwin"* ]] ; then
      pbcopy <<< "$url"
    fi
  done
}

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
  if [[ -s /dev/stdin ]] ; then
    content=$(cat)
  else
    if [[ "$OSTYPE" == "linux-gnu" ]] ; then
      return
    elif [[ "$OSTYPE" == "darwin"* ]] ; then
      content=$(pbpaste)
    fi
  fi
  response=$(curl -XPOST -s -d "$content" "$url/documents")
  url=$(awk -F '"' -v url="$url/raw/" '{print url $4}' <<< "$response")
  echo "$url"
  if [[ "$OSTYPE" == "darwin"* ]] ; then
    pbcopy <<< "$url"
  fi
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

# send push notifications to your mobile device via the web service Pushover
# requires executable from https://github.com/erniebrodeur/pushover
push() {
  if hash pushover 2>/dev/null ; then
    pushover "$*"
  fi
}

# shorten URL using Google API
# requires API KEY from https://developers.google.com/url-shortener
# echo "export GOOGLE_URL_SHORTENER_API_KEY='<your-api-key>'" >>~/.bash/private.bash"
shorten() {
  if [[ -s /dev/stdin ]] ; then
    content=$(cat)
  else
    if [[ "$OSTYPE" == "linux-gnu" ]] ; then
      return
    elif [[ "$OSTYPE" == "darwin"* ]] ; then
      content=$(pbpaste)
    fi
  fi
  response=$(curl -s "https://www.googleapis.com/urlshortener/v1/url?key=$GOOGLE_URL_SHORTENER_API_KEY" -H "Content-Type: application/json" -d "{\"longUrl\": \"$content\"}")
  if grep -q error <<< "$response" ; then
    return
  else
    url=$(echo "$response" | sed -n 3p | cut -d'"' -f4)
  fi
  echo "$url"
  if [[ "$OSTYPE" == "darwin"* ]] ; then
    pbcopy <<< "$url"
  fi
}
