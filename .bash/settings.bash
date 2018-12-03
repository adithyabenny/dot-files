# configure command history
HISTCONTROL=ignoreboth                           # don't store commands if they start with a space, or if they are duplicates
HISTFILE="$HOME/.bash_history"                   # store the history of commands that were executed over here
HISTSIZE='INFINITE'                              # number of lines that are allowed in the history file at the start/end of a session
HISTTIMEFORMAT="%d/%m/%y %T "                    # timestamp format to associate each command with
PROMPT_COMMAND+="history -a; "                   # history buffer to be flushed after every command

# shell options
shopt -s autocd                                  # auto "cd" when entering just a path
shopt -s cdspell                                 # this will correct minor spelling errors in a cd command
shopt -s checkjobs                               # defer the exit if any of the background jobs are running
shopt -s checkwinsize                            # fix line wrap on window resize
shopt -s cmdhist                                 # force multi-line commands to be stored in the history as a single line
shopt -s direxpand                               # replaces directory names with the results of word expansion
shopt -s dirspell                                # auto completes directory names even if there's a minor spelling mistake
shopt -s dotglob                                 # consider filenames beginning with a '.' for filename expansions
shopt -s expand_aliases                          # expand aliases in scripts
shopt -s extglob                                 # enhances pattern matching features
shopt -s globstar                                # expand "**" to match files in subdirectories as well
shopt -s histappend                              # append to history rather than overwrite (avoid histoy loss)
shopt -s hostcomplete                            # tab-completion of hostnames after @
shopt -s nocaseglob                              # let file name expansions be case insensitive
