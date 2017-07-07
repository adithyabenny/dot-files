# Golang specific
export GOPATH="$HOME/go"
if [[ "$OSTYPE" == "linux"* ]] ; then
  export PATH="$PATH:/usr/local/go/bin"
elif [[ "$OSTYPE" == "darwin"* ]] ; then
  export PATH="$PATH:$BREW_PREFIX/opt/go/libexec/bin"
fi
export PATH="$PATH:$GOPATH/bin"

# Java specific
if [[ "$OSTYPE" == "linux"* ]] ; then
  export JAVA_HOME=$(ls -d "/usr/lib/jvm/java"* 2>/dev/null | tail -n1)
elif [[ "$OSTYPE" == "darwin"* ]] ; then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi

# LuaJIT specific
[[ -f "$HOME/torch/install/bin/torch-activate" ]] && source "$HOME/torch/install/bin/torch-activate"

# Perl specific
export PATH="$HOME/perl5/bin${PATH:+:${PATH}}"
export PERL5LIB="/$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_MB_OPT="--install_base \"$HOME/perl5\""
export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"

# Python specific
export PYTHONSTARTUP="$HOME/.pythonrc"
export PATH="$HOME/miniconda3/bin:$PATH"

# Ruby Version Manager specific
export PATH="$PATH:$HOME/.rvm/bin"                                                # Make Ruby binaries discoverable
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"              # Load RVM into a shell session *as a function*
