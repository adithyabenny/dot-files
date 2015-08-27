# tmux
_tmux() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  opts="attach-session bind-key break-pane capture-pane choose-client choose-session choose-window clear-history clock-mode command-prompt confirm-before copy-buffer copy-mode delete-buffer detach-client display-message display-panes down-pane find-window has-session if-shell join-pane kill-pane kill-server kill-session kill-window last-window link-window list-buffers list-clients list-commands list-keys list-panes list-sessions list-windows load-buffer lock-client lock-server lock-session move-window new-session new-window next-layout next-window paste-buffer pipe-pane previous-layout previous-window refresh-client rename-session rename-window resize-pane respawn-window rotate-window run-shell save-buffer select-layout select-pane select-prompt select-window send-keys send-prefix server-info set-buffer set-environment set-option set-window-option show-buffer show-environment show-messages show-options show-window-options source-file split-window start-server suspend-client swap-pane swap-window switch-client unbind-key unlink-window up-pane"

  COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
  return 0
}
complete -F _tmux tmux


# cluster SSH
_cssh()
{
  local cur prev options paroptions clusters extra_cluster_file_line clusters_line extra_cluster_file

  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}

  # all options understood by cssh
  options='-c --cluster-file -C --config-file --debug -e --evaluate \
           -g --tile -G --no-tile -h --help -H --man -l --username \
           -o --options -p --port -q --autoquit -Q --no-autoquit \
           -s --show-history -t --term-args -T --title \
           -u --output-config -v --version'

  # find the extra cluster file line in the .csshrc or, alternatively, /etc/csshrc
  extra_cluster_file_line="`grep '^[[:space:]]*extra_cluster_file' $HOME/.csshrc 2> /dev/null`"
  [ -z "$extra_cluster_file_line" ] && extra_cluster_file_line="`grep '^[[:space:]]*extra_cluster_file' /etc/csshrc 2> /dev/null`"

  # find the clusters line in the .csshrc or, alternatively, /etc/csshrc
  clusters_line="`grep '^[[:space:]]*clusters' $HOME/.csshrc 2> /dev/null`"
  [ -z "$clusters_line" ] && clusters_line="`grep '^[[:space:]]*clusters' /etc/csshrc 2> /dev/null`"

  # extract the location of the extra cluster file
  extra_cluster_file="`echo $extra_cluster_file_line | cut -f 2- -d '='`"
  [ -n "$extra_cluster_file" ] && extra_cluster_file="`eval echo $extra_cluster_file`"
                                                     # TODO: don't use eval to expand ~ and $HOME

  # get the names of all defined clusters
  clusters=$(
  {
    [ -n "$clusters_line" ] && echo "$clusters_line" | cut -f 2- -d '=' | tr "$IFS" "\n" || /bin/true
    [ -n "$extra_cluster_file" ] && sed -e 's/^\([a-z0-9.-]\+\).*$/\1/i' "$extra_cluster_file" 2> /dev/null || /bin/true
    sed -e 's/^\([a-z0-9.-]\+\).*$/\1/i' /etc/clusters 2> /dev/null || /bin/true
  } | sort -u)

  # use options and clusters for tab completion, except there isn't yet
  # at least one character to filter by
  # reason: don't show options if the user types "cssh <tab><tab>"
  paroptions="$clusters"
  [ -n "$cur" ] && paroptions="$paroptions $options"

  case $prev in
  --cluster-file|-c|--config-file|-C)
    COMPREPLY=( $( compgen -o filenames -G "$cur*" ) )
    ;;
  *)
    COMPREPLY=()

    # also use ssh hosts for tab completion if function _known_hosts is present
    [ "`type -t _known_hosts`" = "function" ] && _known_hosts -a

    COMPREPLY=( "${COMPREPLY[@]}" $( compgen -W "$paroptions" | grep "^$cur") )
    ;;
  esac

  return 0
}
complete -F _cssh cssh crsh ctel
