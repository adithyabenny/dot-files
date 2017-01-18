alias ..='cd ..'                                                               # move 1 directory up
alias ..2='cd ../..'                                                           # move 2 directories up
alias ..3='cd ../../..'                                                        # move 3 directories up
alias ..4='cd ../../../..'                                                     # move 4 directories up
alias ..5='cd ../../../../..'                                                  # move 5 directories up
alias cp='cp -v'                                                               # let copy always be verbose
alias dig='dig +short'                                                         # let dig always be succinct
alias l='ls -CF'                                                               # distinguish between file types by suffixing file name with a symbol
alias la='ls -A'                                                               # list all files
alias ld='ls -d */ 2>/dev/null'                                                # list only directories
alias lh='ls -d .??* 2>/dev/null'                                              # list only hidden files
alias ll='ls -alFh'                                                            # list all files with their details
alias mv='mv -v'                                                               # let move always be verbose
alias mkdir='mkdir -pv'                                                        # let mkdir always be verbose, create parent directory if it doesn't exist
if [[ "$OSTYPE" == "linux"* ]] ; then
  alias osv='cat /etc/*-release | sort | uniq'                                 # output Linux distribution
  alias port='sudo netstat -tulpn'                                             # show all listening ports
elif [[ "$OSTYPE" == "darwin"* ]] ; then
  alias port='sudo lsof -nP -itcp -stcp:listen | grep --color=none v4'         # show all IPv4 TCP listening ports
fi
alias pls='sudo $(history -p \!\!)'                                            # re-execute last command with elevated privileges
alias rm='rm -v'                                                               # let remove always be verbose
alias rsync='rsync -avzhP --partial-dir=.rsync-partial'                        # enable compression and partial synchronization
alias sudo='sudo '                                                             # required to enable auto-completion if command is prefixed with sudo
alias service='sudo service'                                                   # let service always run with elevated privileges
alias watch='watch --color '                                                   # let watch output always be colorized
if hash systemctl 2>/dev/null ; then
  alias scl='sudo systemctl'                                                   # let systemctl always run with elevated privileges
  source /usr/share/bash-completion/completions/systemctl                      # load auto-completion for systemctl
  complete -F _systemctl scl                                                   # load auto-completion for its alias as well
fi
alias x=extract                                                                # extract the contents of an archive
alias xargs='xargs -rd\\n '                                                    # set default delimiter to newline instead of whitespace

# load aliases for Fasd
# requires executable from https://github.com/clvv/fasd
if hash fasd 2>/dev/null ; then
  eval "$(fasd --init auto)"
  if [[ "$OSTYPE" == "linux"* ]] ; then
    alias o='a -e xdg-open'
  elif [[ "$OSTYPE" == "darwin"* ]] ; then
    alias o='a -e open -b spotlight'
  fi
  alias v='f -t -e vim -b viminfo'
  _fasd_bash_hook_cmd_complete o v
fi

# upload file to Dropbox and share the link
# requires executable from https://github.com/andreafabrizi/Dropbox-Uploader
# echo "export DROPBOX_SCRIPT='<location-of-dropbox_uploader.sh>'" >>~/.bash/private.bash
dropbox() {
  for file in "$@" ; do
    $DROPBOX_SCRIPT -q upload "$file" /
    if [[ $? -ne 0 ]] ; then
      echo "Upload failed.."
      return 2
    fi
    response=$($DROPBOX_SCRIPT -q share "$file")
    if [[ $? -ne 0 ]] ; then
      echo "Sharing failed.."
      return 2
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
  if [[ -f "$1" ]] ; then
    case "$1" in
      *.7z)       7z x "$1"               ;;
      *.bz2)      bunzip2 "$1"            ;;
      *.exe)      cabextract "$1"         ;;
      *.gz)       gunzip "$1"             ;;
      *.jar)      7z x "$1"               ;;
      *.lzma)     unlzma "$!"             ;;
      *.r+(0))    unrar x "$1"            ;;
      *.rar)      unrar x "$1"            ;;
      *.tar)      tar vxf "$1"            ;;
      *.tar.bz2)  tar vxjf "$1"           ;;
      *.tbz2)     tar vxjf "$1"           ;;
      *.tar.gz)   tar vxzf "$1"           ;;
      *.tgz)      tar vxzf "$1"           ;;
      *.tar.xz)   tar vxJf "$1"           ;;
      *.xz)       unxz "$1"               ;;
      *.zip)      unzip "$1"              ;;
      *.Z)        uncompress "$1"         ;;
      *)
        echo "'$1' cannot be extracted"
        return 2                          ;;
    esac
  else
    echo "'$1' is not a file"
    return 2
  fi
}

# find file by name
ff() {
  find . -type f -iname '*'"$*"'*' -ls 2>/dev/null
}

# upload contents to Haste, an open-source Node.js pastebin
# echo "export PASTEBIN_URL='<url-of-pastebin>'" >>~/.bash/private.bash
pb() {
  if [[ -z "$PASTEBIN_URL" ]] ; then
    url="http://hastebin.com"
  else
    url="$PASTEBIN_URL"
  fi
  if [[ -p /dev/stdin ]] ; then
    content=$(cat)
  else
    if [[ "$OSTYPE" == "linux"* ]] ; then
      return 2
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

# list all network interfaces and their IPs
ipp() {
  interfaces=$(ifconfig | awk -F '[ \t]+' '{print $1}' | sed '/^$/d' | cut -d':' -f1 | grep -v 'lo')
  for interface in $interfaces ; do
    ip=$(ifconfig $interface | grep "inet[^6]" | awk '{print $2}' | cut -d':' -f2)
    if [[ -n "$ip" ]] ; then
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
    pushover "$@"
  fi
}

# shorten URL using Google API
# requires API KEY from https://developers.google.com/url-shortener
# echo "export GOOGLE_URL_SHORTENER_API_KEY='<your-api-key>'" >>~/.bash/private.bash"
shorten() {
  if [[ -p /dev/stdin ]] ; then
    content=$(cat)
  else
    if [[ "$OSTYPE" == "linux"* ]] ; then
      return 2
    elif [[ "$OSTYPE" == "darwin"* ]] ; then
      content=$(pbpaste)
    fi
  fi
  response=$(curl -s "https://www.googleapis.com/urlshortener/v1/url?key=$GOOGLE_URL_SHORTENER_API_KEY" -H "Content-Type: application/json" -d "{\"longUrl\": \"$content\"}")
  if grep -q error <<< "$response" ; then
    return 2
  else
    url=$(echo "$response" | sed -n 3p | cut -d'"' -f4)
  fi
  echo "$url"
  if [[ "$OSTYPE" == "darwin"* ]] ; then
    pbcopy <<< "$url"
  fi
}
