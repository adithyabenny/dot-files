# If not running interactively, don't do anything
if [[ $- != *i* ]] ; then
  return
fi

# enable bash completion in interactive shells
if [[ "$OSTYPE" == "linux"* ]] ; then
  [[ -f /etc/bash_completion ]] && source /etc/bash_completion
  [[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion
elif [[ "$OSTYPE" == "darwin"* ]] ; then
  BREW_PREFIX=$(brew --prefix)
  [[ -f $BREW_PREFIX/share/bash-completion/bash_completion ]] && source $BREW_PREFIX/share/bash-completion/bash_completion
fi

# list of files to source
for file in $(ls ~/.bash/*.bash 2>/dev/null) ; do
  source "$file"
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
if [[ $USER == 'root' ]] ; then
  USERNAME_COLOR='\[\033[1;33m\]'     # yellow
  SENTINEL_CHAR='#'
else
  if [[ -z $SSH_TTY ]] ; then
    USERNAME_COLOR='\[\033[1;34m\]'   # blue
  else
    USERNAME_COLOR='\[\033[1;31m\]'   # red
  fi
  SENTINEL_CHAR='$'
fi
PS1='\[\033[1;33m\]${debian_chroot:+($debian_chroot)}'${USERNAME_COLOR}'\u\[\033[1;32m\]@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\[\033[1;33m\]$git_state\[\033[0m\]'${SENTINEL_CHAR}' '
PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# enable color support for the commonly used binaries
if [[ "$OSTYPE" == "linux"* ]] ; then
  [[ -r ~/.dircolors ]] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
elif [[ "$OSTYPE" == "darwin"* ]] ; then
  export CLICOLOR=1
  export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
fi

# load bindings
export INPUTRC="$HOME/.inputrc"

# default text editor
export EDITOR="vim"

# make less more friendly for non-text input files, see lesspipe(1)
# requires executable from https://github.com/wofr06/lesspipe
export LESSOPEN="|lesspipe.sh %s"

# enable color support within less
# search within less is case insensitive unless the pattern contains uppercase letters
export LESS="-Ri"

# set the MySQL prompt
export MYSQL_PS1="\u@\h [\d]> "

# add the following locations to $PATH if not already present
path_list=('/bin' '/sbin' '/usr/bin' '/usr/sbin' '/usr/local/bin' '/usr/local/sbin')
for path in "${path_list[@]}" ; do
  case ":${PATH:=$path}:" in
    *":$path:"*)
      ;;
    *)
      export PATH="$PATH:$path" ;;
  esac
done
