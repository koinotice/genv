_genv_complete() {
  local word completions
  word="$1"
  completions="$(genv cmplt "${word}")"
  reply=( "${(ps:\n:)completions}" )
}

compctl -f -K _genv_complete genv
