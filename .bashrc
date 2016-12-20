# If not running interactively, don't do anything
if [[ $- != *i* ]] ; then
  return
fi

# make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

# enable bash completion in interactive shells
if [[ "$OSTYPE" == "linux-gnu"* ]] ; then
  if ! shopt -oq posix ; then
    if [[ -f /usr/share/bash-completion/bash_completion ]] ; then
      source /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]] ; then
      source /etc/bash_completion
    fi
  fi
elif [[ "$OSTYPE" == "darwin"* ]] ; then
  if [[ -f $(brew --prefix)/etc/bash_completion ]] ; then
    source $(brew --prefix)/etc/bash_completion
  fi
fi

# list of files to source
for file in ~/.bash/*.bash ; do
 if [[ -f "$file" ]] ; then
   source "$file"
 fi
done

# set variable identifying the chroot you work in (used in the prompt below)
if [[ -z "${debian_chroot:-}" ]] && [[ -r /etc/debian_chroot ]] ; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# load Git info (used in the prompt below)
if type -t __git_ps1 >/dev/null ; then
  export GIT_PS1_SHOWDIRTYSTATE=true
  PROMPT_COMMAND+='git_state=$(__git_ps1 "<%s>"); '
fi

# set the prompt string
PS1='\[\033[1;33m\]${debian_chroot:+($debian_chroot)}\[\033[1;31m\]\u\[\033[1;32m\]@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\[\033[1;33m\]$git_state\[\033[0m\]$ '
PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# enable color support for the commonly used binaries
if [[ "$OSTYPE" == "linux-gnu"* ]] ; then
  if [[ -x /usr/bin/dircolors ]] ; then
    if [[ -r ~/.dircolors ]] ; then
      eval "$(dircolors -b ~/.dircolors)"
    else
      eval "$(dircolors -b)"
    fi
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
  fi
elif [[ "$OSTYPE" == "darwin"* ]] ; then
  export CLICOLOR=1
  export LSCOLORS=GxFxCxDxBxegedabagaced
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# load bindings
export INPUTRC="$HOME/.inputrc"

# default text editor
export EDITOR="vim"

# enable color support within less
# search within less is case insensitive unless the pattern contains uppercase letters
export LESS="-Ri"

# set the MySQL prompt
export MYSQL_PS1="\u@\h [\d]> "

# add the following locations to $PATH if not already present
path_list=('/bin' '/sbin' '/usr/bin' '/usr/sbin' '/usr/local/bin' '/usr/local/sbin')
for i in "${path_list[@]}" ; do
  case ":${PATH:=$i}:" in
    *":$i:"*)
      ;;
    *)
      export PATH="$PATH:$i" ;;
  esac
done

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]] ; then
  #export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"         # coreutils
  #export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
  export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"         # findutils
  export MANPATH="/usr/local/opt/findutils/libexec/gnuman:$MANPATH"
  export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"           # gnu-tar
  export MANPATH="/usr/local/opt/gnu-tar/libexec/gnuman:$MANPATH"
  export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"           # gnu-sed
  export MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"
fi

# Python specific
export PYTHONSTARTUP="$HOME/.pythonrc"

# Golang specific
export GOPATH="$HOME/go"
if [[ "$OSTYPE" == "linux-gnu"* ]] ; then
  export PATH="$PATH:/usr/local/go/bin"
elif [[ "$OSTYPE" == "darwin"* ]] ; then
  export PATH="$PATH:$(brew --prefix)/opt/go/libexec/bin"
fi
export PATH="$PATH:$GOPATH/bin"

# RVM specific
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
