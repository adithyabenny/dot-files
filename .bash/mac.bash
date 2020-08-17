export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"										# findutils
export MANPATH="/usr/local/opt/findutils/libexec/gnuman:$MANPATH"
export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"											# gnu-tar
export MANPATH="/usr/local/opt/gnu-tar/libexec/gnuman:$MANPATH"
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"											# gnu-sed
export MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"
export PATH="/usr/local/share/john/:$PATH"                                    # load scripts from John the Ripper

export HOMEBREW_NO_ANALYTICS=1                                                # disable Homebrew Analytics

alias gls='gls --color=auto'                                                  # export color scheme for GNU ls
alias lck='pmset displaysleepnow'                                             # switch off display
alias paste='gpaste'                                                          # use the GNU version by default
alias shred='gshred -vfzu -n 10'                                              # securely erase the file
alias slp='pmset sleepnow'                                                    # go to sleep

# send notification and make a sound
# requires additional packages
#     `brew install terminal-notifier`
alias notify='terminal-notifier -sound Ping -message'

# change directory to the one open in Finder
cdf() {
    local target
    target=$(
        osascript -e "tell application \"Finder\" to if (count of Finder \
            windows) > 0 then get POSIX path of (target of front Finder \
            window as text)" 2>/dev/null
    )
    if [[ -n $target ]] ; then
        cd "$target"
    else
        echo "No Finder window found" >&2
        return 2
    fi
}

# clears all recent files accessed through the GUI and CLI
# optional additional configuration
#     `echo "export CLEAR_HISTORY_BASH_KEYWORDS='<keyword1:keyword2>'" >>~/.bash/private.bash`
#     `echo "export CLEAR_HISTORY_FASD_PATH='<path1:path2>'" >>~/.bash/private.bash`
clear-history() {
    # clear recent files
    osascript -e "tell application \"System Events\" to click menu item \
        \"Clear Menu\" of menu of menu item \"Recent Items\" of menu of \
        menu bar item \"Apple\" of menu bar of process \"Finder\"" \
        1>/dev/null && \
        echo "Recent files cleared successfully" || \
        echo "Unable to clear recent files" >&2
    # clear recent folders
    osascript -e "tell application \"System Events\" to click menu item \
        \"Clear Menu\" of menu of menu item \"Recent Folders\" of menu of \
        menu bar item \"Go\" of menu bar of process \"Finder\"" \
        1>/dev/null && \
        echo "Recent folders cleared successfully" || \
        echo "Unable to clear recent folders" >&2
    # clear Go to Folder
    defaults delete com.apple.finder GoToField &>/dev/null
    defaults delete com.apple.finder GoToFieldHistory &>/dev/null
    killall Finder && \
        echo "Go to Folder cleared successfully" || \
        echo "Unable to clear Go to Folder" >&2
    # clear VLC's recent files
    osascript -e "tell application \"VLC\" to activate" 1>/dev/null && \
        osascript -e "tell application \"Finder\" to set visible of process \
        \"VLC\" to false" 1>/dev/null && \
        osascript -e "tell application \"System Events\" to click menu item \
        \"Clear Menu\" of menu of menu item \"Open Recent\" of menu of menu \
        bar item \"File\" of menu bar 1 of process \"VLC\"" 1>/dev/null && \
        killall VLC && \
        echo "Recent VLC files cleared successfully" || \
        echo "Unable to clear recent VLC files" >&2
    # clear Bash keywords
    if [[ -n "$CLEAR_HISTORY_BASH_KEYWORDS" ]] ; then
        local hist_file="${HISTFILE:-$HOME/.bash_history}"
        local tmp_file="$(mktemp)"
        echo -e "${CLEAR_HISTORY_BASH_KEYWORDS//:/\\n}" | while read k ; do
            tail -r "$hist_file" | sed "/${k//\//\\/}/,+1d" | tail -r >"$tmp_file" && \
                command cp -f "$tmp_file" "$hist_file"
        done &&  echo "Bash history keywords cleared successfully" || \
            echo "Unable to clear Bash history keywords" >&2
    fi
    # clear Fasd paths
    if [[ -n "$CLEAR_HISTORY_FASD_PATH" ]] ; then
        echo -e "${CLEAR_HISTORY_FASD_PATH//:/\\n}" | while read p ; do
            sed -i "/${p//\//\\/}/d" "${_FASD_DATA:-$HOME/.fasd}"
        done &&  echo "Fasd paths cleared successfully" || \
            echo "Unable to clear Fasd paths" >&2
    fi
}

# unmount all DMGs or external HDDs
# Usage:
#     unmount               unmount the DMGs
#     unmount -e            unmount the HDDs
eject() {
    local volume volumes disk_type label device devices
    volumes=$(diskutil list | grep "/dev/disk")
    [[ "$1" == "-e" ]] && disk_type='external' || disk_type='image'
    while read volume ; do
        if grep -q $disk_type <<< $volume ; then
            label=$(echo $volume | awk '{print $1}')
            devices+=" $label"
        fi
    done <<< $volumes
    for device in $devices ; do
        diskutil eject $device
    done
}


# wrapper for notifying user on the status of an operation on an array of items
# Usage:
#     download() {
#         local operation operation_title operation_item
#         read -r -d '' operation <<'EOF'
#         aria2c "$item" ;    # ensure semicolon for multi-line operations
#         EOF                 # no whitespace to be there to the left of EOF
#         operation="$operation" operation_title="Download" operation_item="file(s)" _notify "$@"
#     }
#     download <file1> <file2>        downloads both files sequentially, then notifies user on Desktop
#     download -p <file>              downloads file, notifies user on Desktop and Cell phone
#     download                        downloads file whose link is there on the clipboard, notifies user on Desktop
_notify() {
    local push_notify words word no_of_arguments total_failed message
    words=""
    push_notify=false
    operation_title="${operation_title:-Job}"
    operation_item="${operation_item:-operation(s)}"
    for word in "$@" ; do
        [[ "$word" == "-p" ]] || [[ "$word" == "--push" ]] && \
            push_notify=true || words+=" $word"
    done
    [[ -z "$words" ]] && words=$(pbpaste)
    no_of_arguments=$(wc -w <<< "$words" | tr -d ' ')
    total_failed=0
    for item in $words ; do
        eval $operation
        [[ $? -ne 0 ]] && total_failed=$(($total_failed + 1))
    done
    if [[ $total_failed -eq 0 ]] ; then
        message="All $no_of_arguments $operation_item completed"
    elif [[ $total_failed -eq $no_of_arguments ]] ; then
        message="All $no_of_arguments $operation_item failed"
    else
        message="$total_failed out of $no_of_arguments $operation_item failed"
    fi
    notify -title "$operation_title" -message "$message"
    $push_notify && push --title "$operation_title" "$message"
    return $total_failed
}

# remove extended attributes for a file downloaded from the internet
whitelist() {
    sudo xattr -rd com.apple.metadata:kMDItemWhereFroms "$@"
    sudo xattr -rd com.apple.quarantine "$@"
}
