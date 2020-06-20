# Golang
export GOPATH="$HOME/go"
if [[ "$OSTYPE" == "linux"* ]] ; then
    export PATH="$PATH:/usr/local/go/bin"
elif [[ "$OSTYPE" == "darwin"* ]] ; then
    export PATH="$PATH:$BREW_PREFIX/opt/go/libexec/bin"
fi
export PATH="$PATH:$GOPATH/bin"

# Java
if [[ "$OSTYPE" == "linux"* ]] ; then
    export JAVA_HOME=$(
        find "/usr/lib/jvm" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | \
                sort -nr -t'-' -k2 | head -n1
    )
elif [[ "$OSTYPE" == "darwin"* ]] ; then
    export JAVA_HOME=$(/usr/libexec/java_home)
fi

# Perl
# PERL_MM_OPT="INSTALL_BASE=$HOME/perl5" cpan local::lib
export PATH="$HOME/perl5/bin${PATH:+:${PATH}}"
export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_MB_OPT="--install_base \"$HOME/perl5\""
export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"

# Python
export PYTHONSTARTUP="$HOME/.pythonrc"
if [[ "$OSTYPE" == "linux"* ]] ; then
    export PATH="$HOME/miniconda3/bin:$PATH"
elif [[ "$OSTYPE" == "darwin"* ]] ; then
    export PATH="$BREW_PREFIX/miniconda3/bin:$PATH"
fi

# Ruby
export PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
