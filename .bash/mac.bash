export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"																# findutils
export MANPATH="/usr/local/opt/findutils/libexec/gnuman:$MANPATH"
export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"																	# gnu-tar
export MANPATH="/usr/local/opt/gnu-tar/libexec/gnuman:$MANPATH"
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"																	# gnu-sed
export MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"

export HOMEBREW_NO_ANALYTICS=1                                                            # disable Homebrew Analytics

alias lck='pmset displaysleepnow'                                                         # switch off display
alias slp='pmset sleepnow'                                                                # go to sleep
alias subl='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl'              # open file with Sublime Text

# change directory to the one open in Finder
cdf() {
  local target
  target=$(osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)' 2>/dev/null)
  if [[ -n $target ]] ; then
    cd "$target"
  else
    echo "No Finder window found" >&2
    return 2
  fi
}

# wrapper for notifying user on the status of an operation on an array of items
# upon completion, the user is notified on the Desktop by default
# pass -p as an argument for an additional Cell phone notification
# the array of items are to be given as arguments to the function
# if no item is given, it will take the first item from the Clipboard
# sample usage:
# download() {
#   local operation operation_title operation_item
#   operation=$(cat <<EOF
#   aria2c "\$item" ;    # ensure semicolon for multi-line operations
#   EOF                  # no whitespace to be there to the left of EOF
#   )
#   operation="$operation" operation_title="Download" operation_item="file(s)" _notify "$@"
# }
# download <file1> <file2>        # downloads both files sequentially, then notifies user on Desktop
# download -p <file>              # downloads file, notifies user on Desktop and Cell phone
# download                        # downloads file whose link is there on the clipboard, notifies user on Desktop
_notify() {
  local push_notify words word no_of_arguments total_failed message
  words=""
  push_notify=false
  operation_title="${operation_title:-Job}"
  operation_item="${operation_item:-operation(s)}"
  for word in "$@" ; do
    [[ "$word" == "-p" ]] && push_notify=true || words+=" $word"
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

# send notification and make a sound
# requires executable from https://github.com/julienXX/terminal-notifier
notify() {
  if hash terminal-notifier 2>/dev/null ; then
    terminal-notifier -sound Ping -message "$@"
  fi
}

# remove extended attributes for a file downloaded from the internet
whitelist() {
  sudo xattr -rd com.apple.metadata:kMDItemWhereFroms "$@"
  sudo xattr -rd com.apple.quarantine "$@"
}
