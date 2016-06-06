# set the number of commands to be remembered by bash
export HISTCONTROL=ignoreboth   # don't store commands if they start with a space, or if they are duplicates
export HISTFILESIZE=1000000     # number of lines that are allowed in the history file at the start/end of a session
export HISTSIZE=1000000         # number of lines stored in memory during a bash session
export HISTTIMEFORMAT="%d/%m/%y %T "        # timestamp format to associate each command with

# shell options
shopt -s autocd 2>/dev/null     # auto "cd" when entering just a path, present in 4.0 and newer versions of bash
shopt -s cdspell                # this will correct minor spelling errors in a cd command
shopt -s checkjobs              # defer the exit if any of the background jobs are running
shopt -s checkwinsize           # fix line wrap on window resize
shopt -s cmdhist                # force multi-line commands to be stored in the history as a single line
shopt -s direxpand 2>/dev/null  # works in conjunction with `dirspell`, present in 4.2 and newer versions of bash
shopt -s dirspell 2>/dev/null   # auto completes directory names even if there's a minor spelling mistake, present in 4.0 and newer versions of bash
shopt -s dotglob                # consider filenames beginning with a '.' for filename expansions
shopt -s expand_aliases         # expand aliases in scripts
shopt -s extglob                # enhances pattern matching features
shopt -s globstar               # expand "**" to match files in subdirectories as well
shopt -s histappend             # append to history rather than overwrite (avoid histoy loss)
shopt -s hostcomplete           # tab-completion of hostnames after @
shopt -s nocaseglob             # let file name expansions be case insensitive

# history buffer to be flushed after every command
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
