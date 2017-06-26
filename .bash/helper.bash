alias ..='cd ..'                                                               # move 1 directory up
alias ..2='cd ../..'                                                           # move 2 directories up
alias ..3='cd ../../..'                                                        # move 3 directories up
alias ..4='cd ../../../..'                                                     # move 4 directories up
alias ..5='cd ../../../../..'                                                  # move 5 directories up
alias cp='cp -v'                                                               # let copy always be verbose
alias dig='dig +short'                                                         # let dig always be succinct
alias egrep='egrep --color=auto '                                              # let egrep output be colorized
alias fgrep='fgrep --color=auto '                                              # let fgrep output be colorized
alias grep='grep --color=auto '                                                # let grep output be colorized
alias gd='git diff'                                                            # shorten Git diff
alias gs='git status'                                                          # shorten Git status
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
  alias osv='sw_vers'                                                          # output Mac system version
  alias port='sudo lsof -nP -itcp -stcp:listen'                                # show all TCP listening ports
fi
alias pls='sudo $(history -p \!\!)'                                            # re-execute last command with elevated privileges
alias rm='rm -v'                                                               # let remove always be verbose
alias rsync='rsync -avzhP --partial-dir=.rsync-partial'                        # enable compression and partial synchronization
alias sudo='sudo '                                                             # required to enable auto-completion if command is prefixed with sudo
alias service='sudo service'                                                   # let service always run with elevated privileges
alias watch='watch --color '                                                   # let watch output always be colorized
if hash systemctl 2>/dev/null ; then
  alias scl='sudo systemctl'                                                   # let systemctl always run with elevated privileges
  complete -F _systemctl scl                                                   # load auto-completion for its alias as well
fi
alias x=extract                                                                # extract the contents of an archive
alias xargs='xargs -rd\\n '                                                    # set default delimiter to newline instead of whitespace
alias zgrep='grep --color=auto '                                               # let zgrep output be colorized
alias zegrep='egrep --color=auto '                                             # let zegrep output be colorized
alias zfgrep='fgrep --color=auto '                                             # let zfgrep output be colorized

# upload file to Google Drive and share the link
# requires executable from https://github.com/prasmussen/gdrive
# echo "export GOOGLE_DRIVE_PARENT_FOLDER='<Id-of-parent-folder-to-upload-in>'" >>~/.bash/private.bash
drive() {
  local action file_id
  if [[ -z $GOOGLE_DRIVE_PARENT_FOLDER ]] ; then
    echo "Please set the environment variable \$GOOGLE_DRIVE_PARENT_FOLDER" >&2
    return 2
  fi
  if [[ "$1" == "-d" ]] ; then
    action="delete"
    shift
  elif [[ "$1" == "-l" ]] ; then
    action="list"
  elif [[ "$1" == -* ]] ; then
    echo "Either pass -d to delete or -l to list" >&2
    return 2
  fi
  if [[ $# -eq 0 ]] || [[ $# -gt 1 ]] ; then
    if [[ $action == "list" ]] ; then
      echo "Don't provide an argument after -l" >&2
    else
      echo "Please provide only one file as the argument" >&2
    fi
    return 2
  fi
  if ! [[ -f "$1" ]]  && [[ -z $action ]] ; then
    echo "The argument has to be a file"
    return 2
  fi
  if [[ $action == "delete" ]] ; then
    file_id=$(gdrive list --order 'createdTime desc' -q "name contains '$1' and '$GOOGLE_DRIVE_PARENT_FOLDER' in parents" | sed -n 2p | awk '{print $1}')
    gdrive delete $file_id
  elif [[ $action == "list" ]] ; then
    gdrive list --order 'createdTime desc' -q "'$GOOGLE_DRIVE_PARENT_FOLDER' in parents"
  else
    gdrive upload --parent "$GOOGLE_DRIVE_PARENT_FOLDER" --share "$1"
  fi
}

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

# extract the contents of an archive
# requires executable from http://p7zip.sourceforge.net/
# requires executable from https://www.cabextract.org.uk/
# requires executable from http://www.rarlab.com
# requires executable from http://www.info-zip.org/pub/infozip/UnZip.html
extract() {
  local file
  if [[ -f "$1" ]] ; then
    file=$(echo "$1" | rev | cut -d'.' -f2- | rev)
    case "$1" in
      *.7z)       7z x "$1"               ;;
      *.bz2)      bunzip2 "$1"            ;;
      *.dmg)      7z x "$1"               ;;
      *.exe)      cabextract "$1"         ;;
      *.gz)       gunzip "$1"             ;;
      *.jar)      7z x "$1"               ;;
      *.iso)      7z x "$1" -o"$file"     ;;
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
        echo "'$1' cannot be extracted" >&2
        return 2                          ;;
    esac
  else
    echo "'$1' is not a file" >&2
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
  local content response url
  [[ -z "$PASTEBIN_URL" ]] && url="http://hastebin.com" || url="$PASTEBIN_URL"
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
  [[ "$OSTYPE" == "darwin"* ]] && pbcopy <<< "$url"
}

# list all network interfaces and their IPs
ipp() {
  local interfaces interface ip
  interfaces=$(ifconfig | awk -F '[ \t]+' '{print $1}' | sed '/^$/d' | cut -d':' -f1 | grep -v 'lo')
  for interface in $interfaces ; do
    ip=$(ifconfig $interface | grep "inet[^6]" | awk '{print $2}' | cut -d':' -f2)
    [[ -n "$ip" ]] && echo -e "$interface\t$ip"
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
  local content response url
  if [[ -z $GOOGLE_URL_SHORTENER_API_KEY ]] ; then
    echo "Please set the environment variable \$GOOGLE_URL_SHORTENER_API_KEY" >&2
    return 2
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
  response=$(curl -s "https://www.googleapis.com/urlshortener/v1/url?key=$GOOGLE_URL_SHORTENER_API_KEY" -H "Content-Type: application/json" -d "{\"longUrl\": \"$content\"}")
  if grep -q error <<< "$response" ; then
    return 2
  else
    url=$(echo "$response" | sed -n 3p | cut -d'"' -f4)
  fi
  echo "$url"
  [[ "$OSTYPE" == "darwin"* ]] && pbcopy <<< "$url"
}
