_harpoon_complete() {
  local word completions
  word="$1"
  completions="$(harpoon cmplt "${word}")"
  reply=( "${(ps:\n:)completions}" )
}

compctl -f -K _harpoon_complete harpoon
