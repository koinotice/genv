_harpoon_complete() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"
  local completions="$(harpoon cmplt "$word")"
  COMPREPLY=( $(compgen -W "$completions" -- "$word") )
}

complete -f -F  _harpoon_complete harpoon
