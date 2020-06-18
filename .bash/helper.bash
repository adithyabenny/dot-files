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

# inspect system
if [[ "$OSTYPE" == "linux"* ]] ; then
    alias osv='cat /etc/*-release | sort | uniq'                               # output Linux distribution
    alias port='sudo netstat -tulpn'                                           # show all listening ports
elif [[ "$OSTYPE" == "darwin"* ]] ; then
    alias osv='sw_vers'                                                        # output Mac system version
    alias port='sudo lsof -nP -i4 -iudp -itcp -stcp:listen | grep -v "\:\*"'   # show all IPv4 ports listening for connections
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
eval "$(fasd --init auto)"
if [[ "$OSTYPE" == "linux"* ]] ; then
    alias o='a -e xdg-open'
elif [[ "$OSTYPE" == "darwin"* ]] ; then
    alias o='a -e open'
fi
alias v='f -t -e vim -b viminfo'
_fasd_bash_hook_cmd_complete o v

# set alias for 'The Fuck' utility
# requires executable from https://github.com/nvbn/thefuck
eval "$(thefuck --alias)"

# shortcut for geolocating IPs
# requires executable from https://packages.debian.org/stretch/geoip-bin
alias geo='geoiplookup'

# send push notifications to your mobile device via the web service Pushover
# requires executable from https://github.com/erniebrodeur/pushover
alias push='pushover'

# converts an IP address to the AS number
# if an ASN is passed, then more details about it will be returned
asn() {
    local prefix domain output asn;
    local input="$1"
    # IPv4
    if [[ $input =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] ; then
        domain="origin.asn.cymru.com"
        prefix="$(echo $input | tr '.' '\n' | tac | paste -sd'.')"
        output="$(
            command dig +short TXT $prefix.$domain | sort | head -n1 | \
                sed -E 's/"//g'
        )"
        asn=$(echo "$output" | cut -d' ' -f1)
        output+=" |$(
            command dig +short TXT AS$asn.asn.cymru.com | sed -E 's/"//g' | \
                rev | cut -d'|' -f1 | rev
        )"
    # IPv6
    elif [[ ${input,,} == *:* ]] ; then
        domain="origin6.asn.cymru.com"
        local hextets=$(
            echo "$input" | sed -E 's/::/:/g' | tr ':' '\n' | \
                sed -E '/^$/d' | wc -l
        )
        local exploded_ip="$(
            echo "$input" | sed -E "s/::/:$(yes "0:" | \
                head -n $((8 - $hextets)) 2>/dev/null | \
                paste -sd '')/g;s/:$//g"
        )"
        local prefix="$(
            echo "$exploded_ip" | tr ':' '\n' | while read line ; do \
                printf "%04x\n" 0x$line ; done | tac | rev | \
                sed -E 's/./&\./g' | paste -sd '' | sed -E 's/\.$//g'
        )"
        output="$(
            command dig +short TXT $prefix.$domain | sort | head -n1 | \
                sed -E 's/"//g'
        )"
        asn=$(echo "$output" | cut -d' ' -f1)
        output+=" |$(
            command dig +short TXT AS$asn.asn.cymru.com | sed -E 's/"//g' | \
                rev | cut -d'|' -f1 | rev
        )"
    # ASN
    elif [[ ${input^^} =~ ^[0-9]+$|^AS[0-9]+$ ]] ; then
        domain="asn.cymru.com"
        prefix=$(echo "AS${input^^}" | sed -E 's/ASAS/AS/g')
        output="$(command dig +short TXT $prefix.$domain | sed -E 's/"//g')"
    else
        echo "Ensure that the argument passed is either an IP or an ASN" >&2
        return 2
    fi
    echo "$output"
}

# extract the contents of an archive
# requires executable from http://p7zip.sourceforge.net/
# requires executable from https://www.cabextract.org.uk/
# requires executable from http://www.rarlab.com
extract() {
    local file
    if [[ -f "$1" ]] ; then
        file=$(echo "$1" | rev | cut -d'.' -f2- | rev)
        case "$1" in
            *.7z)       7z x "$1"               ;;
            *.bz2)      bunzip2 "$1"            ;;
            *.deb)      ar x "$1"               ;;
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
            *.rpm)      tar xzf "$1"            ;;
            *.tar)      tar xf "$1"             ;;
            *.tar.bz2)  tar xjf "$1"            ;;
            *.tbz2)     tar xjf "$1"            ;;
            *.tar.gz)   tar xzf "$1"            ;;
            *.tgz)      tar xzf "$1"            ;;
            *.tar.xz)   tar xJf "$1"            ;;
            *.xz)       unxz "$1"               ;;
            *.zip)      7z x "$1"               ;;
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
    [[ -z "$PASTEBIN_URL" ]] && url="http://hastebin.com" || \
        url="$PASTEBIN_URL"
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
    interfaces=$(
        ifconfig | awk -F '[ \t]+' '{print $1}' | sed '/^$/d' | \
            cut -d':' -f1 | grep -v 'lo'
    )
    for interface in $interfaces ; do
        ips=$(
            ifconfig $interface 2>/dev/null | grep "inet" | \
                sed -E 's/addr:\ ?//g' | awk '{print $2}' | \
                egrep -v "^169\.254|^fe80::"
        )
        if [[ -n "$ips" ]] ; then
            ips_v4=$(echo "$ips" | grep "\." | sort -n | sed 's/^/\t/g')
            ips_v6=$(
                echo "$ips" | grep ":" | sort -n | \
                    sed 's/^/\t/g' | cut -d'/' -f1
            )
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
    command dig +short -4 A myip.opendns.com @resolver1.opendns.com
    command dig +short -6 AAAA myip.opendns.com @resolver1.opendns.com
}
