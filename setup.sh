#!/usr/bin/env bash

"""
Requires additional dependencies:

sudo dnf install -y curl fzf rsync tmux vim
sudo curl -sS https://raw.githubusercontent.com/clvv/fasd/master/fasd -o /usr/local/bin/fasd
"""

function print_usage_and_exit() {
    echo "$USAGE"
    exit ${1:-0}
}

function check_if_installed() {
    if ! type -P "$1" 1>/dev/null ; then
        "'$1' is not installed" >&2
        exit 1
    fi
}


BASENAME=$(basename "$0")
USAGE="Usage: $BASENAME [OPTIONS]
A wrapper script to install the dot files present in this repo. Backups for
existing dot files will be taken prior to copying this over.

--all               install all dot files
--bash              install the bash dot files
--editline          install the editline config file
--fasd              install the fasd config file
--fzf               install the fzf bash hooks
--git               install the git config file
--help              print this help
--readline          install the readline config file
--screen            install the screen config file
--skip-existing     skip installing the dot file if it already exists locally
--ssh               install the ssh config file
--tmux              install the tmux config file
--vim               install the vim config files
"
for arg in "$@"; do
    case "$arg" in
    --all)
        INSTALL_ALL=1
        ;;
    --bash)
        INSTALL_BASH=1
        ;;
    --editline)
        INSTALL_EDITLINE=1
        ;;
    --fasd)
        INSTALL_FASD=1
        ;;
    --fzf)
        INSTALL_FZF=1
        ;;
    --git)
        INSTALL_GIT=1
        ;;
    --help)
        HELP=1
        ;;
    --readline)
        INSTALL_READLINE=1
        ;;
    --skip-existing)
        SKIP_EXISTING=1
        ;;
    --screen)
        INSTALL_SCREEN=1
        ;;
    --ssh)
        INSTALL_SSH=1
        ;;
    --tmux)
        INSTALL_TMUX=1
        ;;
    --vim)
        INSTALL_VIM=1
        ;;
    *)
        print_usage_and_exit 1
        ;;
    esac
done
[[ $HELP == 1 || "$#" -eq 0 ]] && print_usage_and_exit


cd "$(dirname "$0")"
command git submodule update --init --recursive
SOURCE=""
TARGET="$HOME"
EXCLUDE_FILES="--exclude ./.bash/fzf.bindings.bash --exclude ./.bash/fzf.completion.bash"
[[ $SKIP_EXISTING == 1 ]] && OVERWRITE_SETTINGS="--ignore-existing" || OVERWRITE_SETTINGS="--backup --suffix=.bak"
if [[ $INSTALL_ALL == 1 ]] ; then
    INSTALL_BASH=1
    INSTALL_EDITLINE=1
    INSTALL_FASD=1
    INSTALL_FZF=1
    INSTALL_GIT=1
    INSTALL_READLINE=1
    INSTALL_SCREEN=1
    INSTALL_SSH=1
    INSTALL_TMUX=1
    INSTALL_VIM=1
fi
[[ $INSTALL_BASH == 1 ]] && SOURCE+=" ./.bashrc ./.bash_profile ./.bash/*.bash"
[[ $INSTALL_EDITLINE == 1 ]] && SOURCE+=" ./.editrc"
[[ $INSTALL_FASD == 1 ]] && SOURCE+=" ./.fasdrc"
if [[ $INSTALL_FZF == 1 ]] ; then
    check_if_installed "fzf"
    EXCLUDE_FILES=""
fi
[[ $INSTALL_GIT == 1 ]] && SOURCE+=" ./.gitconfig"
[[ $INSTALL_READLINE == 1 ]] && SOURCE+=" ./.inputrc"
[[ $INSTALL_SCREEN == 1 ]] && SOURCE+=" ./.screenrc"
[[ $INSTALL_SSH == 1 ]] && SOURCE+=" ./.ssh"
[[ $INSTALL_TMUX == 1 ]] && SOURCE+=" ./.tmux.conf"
[[ $INSTALL_VIM == 1 ]] && SOURCE+=" ./.vimrc"
[[ "$OSTYPE" != "darwin"* ]] && EXCLUDE_FILES+=" --exclude=./.bash/mac.bash"
check_if_installed "rsync"
command rsync -avzh --copy-links --relative $OVERWRITE_SETTINGS $EXCLUDE_FILES $SOURCE "$TARGET"


if [[ $INSTALL_SSH == 1 ]]; then
    command chmod 700 "$TARGET/.ssh"
    command chmod 644 "$TARGET/.ssh/config"
fi
if [[ $INSTALL_VIM == 1 ]]; then
    check_if_installed "curl"
    command curl --silent -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    check_if_installed "vim"
    command vim +PlugInstall +qall
fi
