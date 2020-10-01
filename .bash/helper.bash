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
    alias osv='cat /etc/os-release'                                            # output Linux distribution
    alias port='sudo ss -tulpn'                                                # show all listening ports
elif [[ "$OSTYPE" == "darwin"* ]] ; then
    alias osv='sw_vers'                                                        # output Mac system version
    alias port='sudo lsof -nP -iudp -itcp -stcp:listen | grep -v ":\*"'        # show all ports listening for connections
fi

# run with specific settings
alias mkdir='mkdir -p'                                                         # create parent directory if it doesn't exist
alias rsync='rsync -avzhPLK --partial-dir=.rsync-partial'                      # enable compression and partial synchronization
alias xargs='xargs -rd\\n '                                                    # set default delimiter to newline instead of whitespace

# colorize output
if [[ "$OSTYPE" == "linux"* ]] ; then
    alias ls='ls --color=auto'
fi
alias grep='grep --color=auto '
alias watch='watch --color '

# shortcut for geolocating IPs
# requires additional packages
#     `dnf install GeoIP GeoIP-GeoLite-data-extra`
alias geo='geoiplookup'

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
        [[ -z "$output" ]] && return
        asn=$(echo "$output" | cut -d' ' -f1)
        output+=" |$(
            command dig +short TXT AS$asn.asn.cymru.com | \
                awk -F'|' '{gsub(/"/, ""); print $5}'
        )"
    # IPv6
    elif [[ ${input,,} == *:* ]] ; then
        domain="origin6.asn.cymru.com"
        local hextets=$(
            echo "$input" | sed 's/::/:/g;s/:/\n/g' | sed '/^$/d' | wc -l
        )
        local exploded_ip="$(
            echo "$input" | sed -E "s/::/:$(yes "0:" | \
                head -n $((8 - $hextets)) 2>/dev/null | \
                paste -sd '')/g;s/^://g;s/:$//g"
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
        [[ -z "$output" ]] && return
        asn=$(echo "$output" | cut -d' ' -f1)
        output+=" |$(
            command dig +short TXT AS$asn.asn.cymru.com | \
                awk -F'|' '{gsub(/"/, ""); print $5}'
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
# requires additional packages
#     `dnf install binutils cabextract p7zip p7zip-plugins unrar xz`
extract() {
    if [[ -f "$1" ]] ; then
        case "$1" in
            *.7z)       7z x "$1"               ;;
            *.tar.bz2)  tar xjf "$1"            ;;
            *.bz2)      bunzip2 "$1"            ;;
            *.deb)      ar x "$1"               ;;
            *.exe)      cabextract "$1"         ;;
            *.tar.gz)   tar xzf "$1"            ;;
            *.gz)       gunzip "$1"             ;;
            *.jar)      7z x "$1"               ;;
            *.iso)      7z x "$1" -o"${1%.*}"   ;;
            *.lzma)     unlzma "$!"             ;;
            *.r0)       unrar x "$1"            ;;
            *.r00)      unrar x "$1"            ;;
            *.r000)     unrar x "$1"            ;;
            *.rar)      unrar x "$1"            ;;
            *.rpm)      tar xzf "$1"            ;;
            *.tar)      tar xf "$1"             ;;
            *.tbz2)     tar xjf "$1"            ;;
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

# list all network interfaces and their IPs
ipp() {
    local interfaces ips
    interfaces="$(
        ifconfig | awk '!/^\s+/ && !/^$/ {gsub(/:$/, "", $1); print $1}'
    )"
    for i in $interfaces ; do
        ips="$(
            ifconfig $i 2>/dev/null | awk '{gsub(/addr: */, "")} /inet/ && \
                !/inet 127/ && !/inet6 ::1/ && !/inet 169.254/ && \
                !/inet6 fe80::/ {print "\t"$2}'
        )"
        [[ -n "$ips" ]] && echo -e "${i}${ips}"
    done
}

# like mv, but with progress bar
msync() {
    rsync --remove-source-files "$@"
    if [[ $? -eq 0 ]] && [[ -d "$1" ]] ; then
        find "$1" -type d -empty -delete
    fi
}

# upload contents to Haste, an open-source Node.js pastebin
# if no input is passed, then the contents of the clipboard will be used
# requires additional configuration
#     `echo "export PASTEBIN_URL='<url-of-pastebin>'" >>~/.bash/private.bash`
#     `echo "export PASTEBIN_AUTH_BASIC='user:pass'" >>~/.bash/private.bash`
pb() {
    local pb_url content response short_url
    local curl_auth_arg=""
    pb_url="${PASTEBIN_URL:-https://hastebin.com/}"
    if [[ -p /dev/stdin ]] ; then
        content="$(cat)"
    elif [[ "$OSTYPE" == "darwin"* ]] ; then
        content="$(pbpaste)"
    else
        return 2
    fi
    [[ -n $PASTEBIN_AUTH_BASIC ]] && curl_auth_arg="-u $PASTEBIN_AUTH_BASIC"
    response="$(
        echo "$content" | \
            curl -sS -XPOST $curl_auth_arg --data-binary @- "$pb_url/documents"
    )"
    short_url="$pb_url/$(echo "$response" | cut -d'"' -f4)"
    echo "$short_url"
    [[ "$OSTYPE" == "darwin"* ]] && echo -n "$short_url" | pbcopy
}

# show public IP
pipp() {
    local DIG_OPTS="+short +timeout=1 +retry=1 \
        myip.opendns.com @resolver1.opendns.com"
    command dig -4 A $DIG_OPTS
    command dig -6 AAAA $DIG_OPTS
}

# upload contents to Sprunge, a public pastebin
# if no input is passed, then the contents of the clipboard will be used
ppb() {
    local content short_url
    if [[ -p /dev/stdin ]] ; then
        content="$(cat)"
    elif [[ "$OSTYPE" == "darwin"* ]] ; then
        content="$(pbpaste)"
    else
        return 2
    fi
    short_url="$(echo "$content" | curl -sS -F 'sprunge=<-' http://sprunge.us)"
    echo "$short_url"
    [[ "$OSTYPE" == "darwin"* ]] && echo -n "$short_url" | pbcopy
}

# send push notifications to your mobile device via the service Pushover
# requires additional configuration
#     `echo "export PUSHOVER_USER='<user>'" >>~/.bash/private.bash`
#     `echo "export PUSHOVER_TOKEN='<token>'" >>~/.bash/private.bash`
# token can be fetched from here (https://pushover.net/apps/build)
# Usage:
#     push foo              sends the message 'foo'
#     push -h bar           sends the message 'bar' with high priority
push() {
    local priority=0
    [[ "$1" == "-h" ]] || [[ "$1" == "--high" ]] && priority=1 && shift
    local message="$1"
    if [[ -z "$message" ]] ; then
        echo "Please pass a message to push as an argument" >&2
        return 2
    fi
    curl -sS --form-string "user=$PUSHOVER_USER" \
        --form-string "token=$PUSHOVER_TOKEN" \
        --form-string "priority=$priority" \
        --form-string "message=$1" \
        "https://api.pushover.net/1/messages.json" 1>/dev/null
}


# shorten the given URL using Shlink, an open-source URL Shortener
# requires additional packages
#     `dnf install jq`
# requires additional configuration
#     `echo "export URL_SHORTENER_ENDPOINT='<url-of-endpoint>'" >>~/.bash/private.bash`
#     `echo "export URL_SHORTENER_API_KEY='<generated-api-key>'" >>~/.bash/private.bash`
# API key can be generated from by running `bin/cli api-key:generate`
# Usage:
#     url-shorten <url>             Shortens the given URL, uses a randomized 4-letter slug
#     url-shorten <url> <slug>      Shortens the given URL using the given slug
#                                   If slug already exists, then it overwrites it
url-shorten() {
    local url result short_url custom_slug
    local url="$1"
    if [[ -z $url ]] ; then
        echo "Please pass the URL as the first argument" >&2
        return 2
    elif [[ ! $url =~ ^https?://[^\ ]+$ ]] ; then
        echo "'$url' is not a valid URL" >&2
        return 2
    fi
    [[ -n "$2" ]] && custom_slug=", \"customSlug\": \"$2\""
    result="$(
        curl -sS -X POST "$URL_SHORTENER_ENDPOINT/rest/v2/short-urls" \
            -H "X-Api-Key: $URL_SHORTENER_API_KEY" \
            -H "Content-Type: application/json" \
            -d "{\"longUrl\": \"$url\"$custom_slug}"
    )"
    if [[ "$(jq '.type' <<< "$result")" == "\"INVALID_SLUG\"" ]] ; then
       curl -sS -X PATCH "$URL_SHORTENER_ENDPOINT/rest/v2/short-urls/$2" \
            -H "X-Api-Key: $URL_SHORTENER_API_KEY" \
            -H "Content-Type: application/json" \
            -d "{\"longUrl\": \"$url\"}" && \
            result="{\"shortUrl\": \"$URL_SHORTENER_ENDPOINT/$2\"}"
    fi
    short_url="$(jq '.shortUrl' <<< "$result" | sed -E 's/"//g')"
    echo "$short_url"
    [[ "$OSTYPE" == "darwin"* ]] && echo -n "$short_url" | pbcopy
}
