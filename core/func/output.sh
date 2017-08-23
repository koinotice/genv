#!/usr/bin/env bash

export COLOR_NC='\e[0m' # No Color
export COLOR_DIM='\e[2m'
export COLOR_WHITE='\e[1;37m'
export COLOR_BLACK='\e[0;30m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_LIGHT_YELLOW="\e[93m"
export COLOR_GRAY='\e[0;30m'
export COLOR_LIGHT_GRAY='\e[0;37m'
export COLOR_DARK_GRAY='\e[0;90m'
export BG_COLOR_LIGHT_GREY="\e[100m" # Background

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

speak_greeting() {
	if [[ -v GREETING && ! -v CI ]]; then
		export HARPOON_SPEECH_RATE=225
		if [ -x "$(command -v finger)" ]; then
			name=$(finger `whoami` | awk -F: '{ print $3 }' | head -n1 | sed 's/^ //' | cut -d " " -f 1)
		fi
		msg="Hey ${name:-}! ${GREETING}"
		$(sleep 5 && speak "${msg}") &
		if [[ ${HARPOON_SPEECH} == false ]]; then
			echo -e "\n${COLOR_LIGHT_PURPLE}${msg}${COLOR_NC}\n"
		fi
	fi
}

print_info() {
	echo -e "${COLOR_PURPLE}${1}${COLOR_NC}${2:-}"
}

speak_info() {
	speak "$1"
	print_info "$1" "${2:-}"
}

print_success() {
	echo -e "${COLOR_GREEN}${1}${COLOR_NC}${2:-}"
}

speak_success() {
	speak "$1"
	print_success "$1" "${2:-}"
}

print_warn() {
	echo -e "${COLOR_LIGHT_YELLOW}${1}${COLOR_NC}${2:-}"
}

print_error() {
	echo -e "${COLOR_RED}${1}${COLOR_NC}${2:-}" >&2
}

print_panic() {
	print_error "${1}" "${2:-}" >&2 && exit 1
}

print_debug() {
	if [ ${HARPOON_DEBUG:-} ]; then
		log_debug "$1"
		echo -e "${COLOR_DIM}${1}${COLOR_NC}" >&2
	fi
}

log_debug() {
	if [ ${HARPOON_DEBUG:-} ]; then
		echo -e "[$(date)] ${1}" >> ${HARPOON_TEMP}/debug.log
	fi
}

print_usage() {
	echo "Usage:"
	echo "  harpoon <command> [<arg>...]"
	echo "  harpoon -h|--help"
}