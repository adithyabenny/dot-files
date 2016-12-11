# all of this is specific to just macOS

# send notification and make a sound
# requires executable from https://github.com/julienXX/terminal-notifier
notify() {
  if hash terminal-notifier 2>/dev/null ; then
    terminal-notifier -sound Ping -message "$*"
  fi
}

# remove quarantine flag from this directory
whitelist() {
  sudo xattr -rd com.apple.quarantine "$*"
}
