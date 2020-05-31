# move up the directory
alias ..='cd ..'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'
alias ..5='cd ../../../../..'

# always be verbose/succinct
alias cp='cp -v'
alias dig='dig +short'
alias mv='mv -v'
alias rm='rm -v'

# shorten frequently used commands
alias ga='git add -A' && __git_complete ga _git_add 2>/dev/null
alias gd='git diff' && __git_complete gd _git_diff 2>/dev/null
alias gl='git lg' && __git_complete gl _git_log 2>/dev/null
alias gs='git status' && __git_complete gs _git_status 2>/dev/null
alias l='ls -CF'                                                               # distinguish between file types by suffixing file name with a symbol
alias la='ls -A'                                                               # list all files
alias ld='ls -d */ 2>/dev/null'                                                # list only directories
alias lh='ls -d .??* 2>/dev/null'                                              # list only hidden files
alias ll='ls -alFh'                                                            # list all files with their details
alias x='extract'                                                              # extract the contents of an archive

# run with elevated privileges
alias mtr='sudo mtr'
alias pls='sudo $(history -p \!\!)'                                            # re-execute last command with elevated privileges
alias sudo='sudo '                                                             # required to enable auto-completion if alias is prefixed with sudo
alias service='sudo service'
if hash systemctl 2>/dev/null ; then
  source /usr/share/bash-completion/completions/systemctl
  alias scl='sudo systemctl' && complete -F _systemctl scl
fi

# show status
if [[ "$OSTYPE" == "linux"* ]] ; then
  alias osv='cat /etc/*-release | sort | uniq'                                 # output Linux distribution
  alias port='sudo netstat -tulpn'                                             # show all listening ports
elif [[ "$OSTYPE" == "darwin"* ]] ; then
  alias osv='sw_vers'                                                          # output Mac system version
  alias port='sudo lsof -nP -i4 -iudp -itcp -stcp:listen | grep -v "\:\*"'     # show all IPv4 ports listening for connections
fi

# run with specific settings
alias mkdir='mkdir -p'                                                         # create parent directory if it doesn't exist
alias rsync='rsync -avzhPLK --partial-dir=.rsync-partial'                      # enable compression and partial synchronization
alias xargs='xargs -rd\\n '                                                    # set default delimiter to newline instead of whitespace

# colorize output
if [[ "$OSTYPE" == "linux"* ]] ; then
  alias dir='dir --color=auto'
  alias ls='ls --color=auto'
  alias vdir='vdir --color=auto'
fi
alias egrep='egrep --color=auto '
alias fgrep='fgrep --color=auto '
alias grep='grep --color=auto '
alias watch='watch --color '
alias zgrep='grep --color=auto '
alias zegrep='egrep --color=auto '
alias zfgrep='fgrep --color=auto '

# load aliases for Fasd
# requires executable from https://github.com/clvv/fasd
if hash fasd 2>/dev/null ; then
  eval "$(fasd --init auto)"
  if [[ "$OSTYPE" == "linux"* ]] ; then
    alias o='a -e xdg-open'
  elif [[ "$OSTYPE" == "darwin"* ]] ; then
    alias o='a -e open'
  fi
  alias v='f -t -e vim -b viminfo'
  _fasd_bash_hook_cmd_complete o v
fi

# shortcut for geolocating IPs
# requires executable from https://packages.debian.org/stretch/geoip-bin
alias geo='geoiplookup'

# send push notification when command runs successfully
alert-on-success() {
  local command="$1"
  local alert_msg="${2:-The command \`$command\` has run successfully!}"
  while true ; do
    sleep 1
    eval "$command"
    local exit_code=($?)
    echo
    if [[ $exit_code -eq 0 ]] ; then
      push "$alert_msg"
      break
    fi
  done
}

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
      *.r0)       unrar x "$1"            ;;
      *.r00)      unrar x "$1"            ;;
      *.r000)     unrar x "$1"            ;;
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
  find -L . -type f -iname '*'"$*"'*' -ls 2>/dev/null
}

# search the command line history and show the matches
his() {
  grep "$*" "$HISTFILE" | less +G
}

# like mv, but with progress bar
msync() {
  rsync --remove-source-files "$@"
  if [[ $? -eq 0 ]] && [[ -d "$1" ]] ; then
    find "$1" -type d -empty -delete
  fi
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
  local interfaces interface ips ips_v4 ips_v6
  interfaces=$(ifconfig | awk -F '[ \t]+' '{print $1}' | sed '/^$/d' | cut -d':' -f1 | grep -v 'lo')
  for interface in $interfaces ; do
    ips=$(ifconfig $interface 2>/dev/null | grep "inet" | sed -E 's/addr:\ ?//g' | awk '{print $2}' | egrep -v "^169\.254|^fe80::")
    if [[ -n "$ips" ]] ; then
      ips_v4=$(echo "$ips" | grep "\." | sort -n | sed 's/^/\t/g')
      ips_v6=$(echo "$ips" | grep ":" | sort -n | sed 's/^/\t/g' | cut -d'/' -f1)
      if [[ -z "$ips_v4" ]] ; then
        ips="$interface:$ips_v6"
      elif [[ -z "$ips_v6" ]] ; then
        ips="$interface:$ips_v4"
      else
        ips="$interface:$ips_v4\n$ips_v6"
      fi
      echo -e "$ips"
    fi
  done
}

# show public IP
pipp() {
  dig +short -4 A myip.opendns.com @resolver1.opendns.com
  dig +short -6 AAAA myip.opendns.com @resolver1.opendns.com
}

# send push notifications to your mobile device via the web service Pushover
# requires executable from https://github.com/erniebrodeur/pushover
push() {
  pushover "$@"
}
