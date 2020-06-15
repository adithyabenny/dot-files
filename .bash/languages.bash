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
        find "/usr/lib/jvm" -maxdepth 1 -mindepth 1 -type d | \
                sort -nr -t'-' -k2 | head -n1
    )
elif [[ "$OSTYPE" == "darwin"* ]] ; then
    export JAVA_HOME=$(/usr/libexec/java_home)
fi

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
