alias slp='pmset displaysleepnow'                                                         # switch off display and go to sleep
alias subl='/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl'              # open file with Sublime Text

# change directory to the one open in Finder
cdf() {
  target=$(osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)' 2>/dev/null)
  if [[ -n $target ]] ; then
    cd "$target"
  else
    echo "No Finder window found" >&2
    return 2
  fi
}

# send notification and make a sound
# requires executable from https://github.com/julienXX/terminal-notifier
notify() {
  if hash terminal-notifier 2>/dev/null ; then
    terminal-notifier -sound Ping -message "$*"
  fi
}

# remove extended attributes for a file downloaded from the internet
whitelist() {
  sudo xattr -rd com.apple.metadata:kMDItemWhereFroms "$@"
  sudo xattr -rd com.apple.quarantine "$@"
}
