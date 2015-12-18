# If not running interactively, don't do anything
if [[ $- != *i* ]] ; then
  return
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ] ; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# load Git info
if [ -f ~/.bash/git-prompt.sh ] ; then
  . ~/.bash/git-prompt.sh
fi
export GIT_PS1_SHOWDIRTYSTATE=true

# set the prompt string
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;34m\]\u\[\033[01;32m\]@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;33m\]$(__git_ps1 "<%s>")\[\033[0m\]$ '

# enable color support for the commonly used binaries
if [ -x /usr/bin/dircolors ] ; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ] ; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ] ; then
    . /etc/bash_completion
  fi
fi

# load bindings
export INPUTRC="~/.inputrc"

# default text editor
export EDITOR="vim"

# set the MySQL prompt
export MYSQL_PS1="\u@\h [\d]> "

# Python specific
export PYTHONSTARTUP="$HOME/.pythonrc"

# RVM specific
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Golang specific
export GOPATH="$HOME/go"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$GOPATH/bin"

# Android specific
export PATH="$PATH:$HOME/Android/Sdk/platform-tools"

# list of files to source
for file in ~/.bash/*.bash ; do
 if [ -f "$file" ] ; then
   . "$file"
 fi
done

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
