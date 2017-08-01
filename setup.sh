#!/usr/bin/env bash

BASENAME=$(basename "$0")
USAGE="Usage: $BASENAME [OPTIONS]
A wrapper script to install the dot files present in this repo. Backups for
existing dot files will be taken prior to copying this over.

-h, --help            print this help
-a, --all             install all dot files
-e, --existing        skip file if it already exists
--bash                install the bash dot files
--editline            install the editline config file
--fasd                install the fasd config file
--git                 install the git config file
--readline            install the readline config file
--python              install the python config file
--screen              install the screen config file
--ssh                 install the ssh config file
--tmux                install the tmux config file
--vim                 install the vim config files
"

print_usage_and_exit() {
  echo "$USAGE"
  exit ${1:-0}
}

for arg in "$@" ; do
  case "$arg" in
    --help)
      HELP=1;;
    --all)
      INSTALL_ALL=1;;
    --existing)
      SKIP_EXISTING=1;;
    --bash)
      INSTALL_BASH=1;;
    --editline)
      INSTALL_EDITLINE=1;;
    --fasd)
      INSTALL_FASD=1;;
    --git)
      INSTALL_GIT=1;;
    --readline)
      INSTALL_READLINE=1;;
    --python)
      INSTALL_PYTHON=1;;
    --screen)
      INSTALL_SCREEN=1;;
    --ssh)
      INSTALL_SSH=1;;
    --tmux)
      INSTALL_TMUX=1;;
    --vim)
      INSTALL_VIM=1;;
    -[!-]*)
      OPTIND=1
      while getopts ":hae" short_arg $arg ; do
        case "$short_arg" in
          h)
            HELP=1;;
          a)
            INSTALL_ALL=1;;
          e)
            SKIP_EXISTING=1;;
          *)
            print_usage_and_exit 1;;
        esac
      done;;
    *)
      print_usage_and_exit 1;;
  esac
done

[[ $HELP == 1 || -z "$@" ]] && print_usage_and_exit


SRC_DIR=$(dirname "$0")
SOURCE=""
TARGET="$HOME"
EXCLUDE_FILES='--exclude={*.swp,.git,.gitignore,README.md,setup.sh}'
[[ "$OSTYPE" != "darwin"* ]]  && EXCLUDE_FILES+=' --exclude=mac.bash'
[[ $SKIP_EXISTING == 1 ]]     && OVERWRITE_SETTINGS='--ignore-existing' || OVERWRITE_SETTINGS='--backup --suffix=.bak'
[[ $INSTALL_ALL == 1 ]]       && SOURCE+=" $SRC_DIR/"
[[ $INSTALL_BASH == 1 ]]      && SOURCE+=" $SRC_DIR/{.bash,.bashrc,.bash_profile}"
[[ $INSTALL_EDITLINE == 1 ]]  && SOURCE+=" $SRC_DIR/.editrc"
[[ $INSTALL_FASD == 1 ]]      && SOURCE+=" $SRC_DIR/.fasdrc"
[[ $INSTALL_GIT == 1 ]]       && SOURCE+=" $SRC_DIR/.gitconfig"
[[ $INSTALL_READLINE == 1 ]]  && SOURCE+=" $SRC_DIR/.inputrc"
[[ $INSTALL_PYTHON == 1 ]]    && SOURCE+=" $SRC_DIR/.pythonrc"
[[ $INSTALL_SCREEN == 1 ]]    && SOURCE+=" $SRC_DIR/.screenrc"
[[ $INSTALL_SSH == 1 ]]       && SOURCE+=" $SRC_DIR/.ssh"
[[ $INSTALL_TMUX == 1 ]]      && SOURCE+=" $SRC_DIR/.tmux.conf"
[[ $INSTALL_VIM == 1 ]]       && SOURCE+=" $SRC_DIR/{.vim,.vimrc}"

rsync -avzh $OVERWRITE_SETTINGS $(eval "echo $EXCLUDE_FILES") $(eval "echo $SOURCE") "$TARGET"

if [[ $INSTALL_ALL == 1 || $INSTALL_SSH == 1 ]] ; then
  chmod 700 "$TARGET" "$TARGET/.ssh"
  chmod 644 "$TARGET/.ssh/config"
fi
