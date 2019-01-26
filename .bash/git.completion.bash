_git_ru() {
  local cur pos REMOTES
  cur=${COMP_WORDS[COMP_CWORD]}
  pos=${COMP_CWORD}
  REMOTES=$(git remote show)
  COMPREPLY=()
  if [[ pos -eq 2 ]] ; then
    COMPREPLY=( $(compgen -W "$REMOTES" "$cur") )
  fi
}
