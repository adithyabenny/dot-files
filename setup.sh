#!/usr/bin/env bash

SOURCE=$(dirname "$0")
TARGET="$HOME"
rsync -avzh --backup --suffix=.bak --exclude={*.swp,.git,README.md,setup.sh} "$SOURCE/" "$TARGET"

chmod 700 "$TARGET" "$TARGET/.ssh"
chmod 644 "$TARGET/.ssh/config"

[[ "$OSTYPE" != "darwin"* ]] && rm "$TARGET/.bash/mac.bash"
