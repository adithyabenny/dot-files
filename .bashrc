# If not running interactively, don't do anything
if [[ $- != *i* ]] ; then
    return
fi

# enable bash completion in interactive shells
if [[ "$OSTYPE" == "linux"* ]] ; then
    [[ -f /etc/bash_completion ]] && source /etc/bash_completion
    [[ -f /usr/share/bash-completion/bash_completion ]] && \
        source /usr/share/bash-completion/bash_completion
elif [[ "$OSTYPE" == "darwin"* ]] ; then
    BREW_PREFIX=$(brew --prefix)
    [[ -f $BREW_PREFIX/share/bash-completion/bash_completion ]] && \
        source $BREW_PREFIX/share/bash-completion/bash_completion
fi

# add the following locations to $PATH if not already present
path_list=(
    "/bin"
    "/sbin"
    "/usr/bin"
    "/usr/sbin"
    "/usr/local/bin"
    "/usr/local/sbin"
    "$HOME/bin"
)
for p in "${path_list[@]}" ; do
    [[ ":$PATH:" != *":$p:"* ]] && PATH="$p:${PATH}"
done

# list of files to source
for file in $HOME/.bash/*.bash ; do
    source "$file"
done

# when over SSH, attach to Tmux right away if present
[[ -n $SSH_CONNECTION ]] && [[ -z $DONT_TMUX_ATTACH ]] && [[ -z $TMUX ]] \
    && tmux attach &>/dev/null

# load Git info (used in the prompt below)
if type -t __git_ps1 >/dev/null ; then
    export GIT_PS1_SHOWDIRTYSTATE=true
    PROMPT_COMMAND+='git_state=$(__git_ps1 "<%s>"); '
fi
# set the prompt string
USERNAME_COLOR='\[\033[1;34m\]'         # blue
SENTINEL_CHAR='$'
if [[ -f "/.dockerenv" ]] ; then        # inverted blue
    CONTAINER='\[\033[1;104m\](docker)\[\033[0m\] '
elif [[ $USER == 'root' ]] ; then       # yellow
    USERNAME_COLOR='\[\033[1;33m\]'
    SENTINEL_CHAR='#'
elif [[ -n $SSH_CONNECTION ]] ; then    # red
    USERNAME_COLOR='\[\033[1;31m\]'
fi
PS1=${CONTAINER}
PS1+=${USERNAME_COLOR}'\u'              # user
PS1+='\[\033[0m\]\[\033[1;32m\]@\h'     # hostname
PS1+='\[\033[0m\]:\[\033[1;34m\]\w'     # working directory
PS1+='\[\033[1;33m\]$git_state'         # git branch
PS1+='\[\033[0m\]'${SENTINEL_CHAR}' '
PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# set the MySQL prompt
export MYSQL_PS1="\u@\h [\d]> "

# enable color support for the commonly used binaries
if [[ "$OSTYPE" == "linux"* ]] ; then
    [[ -r ~/.dircolors ]] && eval "$(dircolors -b ~/.dircolors)" || \
        eval "$(dircolors -b)"
elif [[ "$OSTYPE" == "darwin"* ]] ; then
    export CLICOLOR=1
    export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
fi

# load custom key bindings
export INPUTRC="$HOME/.inputrc"

# default text editor
export EDITOR="vim"

# make less more friendly for non-text input files, see lesspipe(1)
# requires executable from https://github.com/wofr06/lesspipe
export LESSOPEN="|lesspipe %s"
# enable color support within less
# search within less is case insensitive unless the pattern contains uppercase letters
export LESS="-Ri"
