_genv_complete() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"
  local completions="$(genv cmplt "$word")"
  COMPREPLY=( $(compgen -W "$completions" -- "$word") )
}

complete -f -F  _genv_complete genv
