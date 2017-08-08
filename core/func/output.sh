#!/usr/bin/env bash

export LTBLU="\033[36m"
export GREEN="\033[0;32m"
export RED="\033[0;31m"
export PURPLE="\033[0;35m"
export LTYELLOW="\e[93m"
export LTGREYBK="\e[100m"
export NC="\033[0m"

if [ ! -v HARPOON_SPEECH ]; then
	export HARPOON_SPEECH=true
fi

if [ ! -v HARPOON_VOICE ]; then
	export HARPOON_VOICE="Fred"
fi

if [ ! -v HARPOON_SPEECH_RATE ]; then
	export HARPOON_SPEECH_RATE=200
fi

if [ ! -v HARPOON_USE_EMOJI ]; then
	export HARPOON_USE_EMOJI=true
fi

if [[ ${HARPOON_USE_EMOJI} == true ]]; then
	export UP="👍"
	export DOWN="👎"
else
	export UP="Up"
	export DOWN="Down"
fi

speak() {
	if [[ $(uname) == 'Darwin' && ${HARPOON_SPEECH} == true ]]; then
		speech=$(echo -e "$1" | sed 's/\n//g')
		say -v ${HARPOON_VOICE} -r ${HARPOON_SPEECH_RATE} "${speech}" &
	fi
}

print_info() {
	echo -e "${PURPLE}${1}${NC}${2:-}"
}

speak_info() {
	speak "$1"
	print_info "$1" "${2:-}"
}

print_success() {
	echo -e "${GREEN}${1}${NC}${2:-}"
}

speak_success() {
	speak "$1"
	print_success "$1" "${2:-}"
}

print_warn() {
	echo -e "${LTYELLOW}${1}${NC}${2:-}"
}

print_error() {
	echo -e "${RED}${1}${NC}${2:-}" >&2
}

print_panic() {
	print_error "${1}" "${2:-}" >&2 && exit 1
}

print_debug() {
	if [ ${HARPOON_DEBUG:-} ]; then
		log_debug "$1"
		echo -e "${LTGREYBK}${1}${NC}" >&2
	fi
}

log_debug() {
	if [ ${HARPOON_DEBUG:-} ]; then
		echo -e "[$(date)] ${1}" >> ${HARPOON_TEMP}/debug.log
	fi
}