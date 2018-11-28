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

#% 🔺 GENV_SPEECH %% Speak important notifications (macOS only) %% true
if [ ! -v GENV_SPEECH ]; then
	export GENV_SPEECH=true
fi

#% 🔺 GENV_VOICE %% Speech voice %% Fred
if [ ! -v GENV_VOICE ]; then
	export GENV_VOICE="Fred"
fi

#% 🔺 GENV_SPEECH_RATE %% Speech rate %% 200
if [ ! -v GENV_SPEECH_RATE ]; then
	export GENV_SPEECH_RATE=200
fi

#% 🔺 GENV_USE_EMOJI %% Use emoji for boolean indicators %% true
if [ ! -v GENV_USE_EMOJI ]; then
	export GENV_USE_EMOJI=true
fi

if [[ ${GENV_USE_EMOJI} == true ]]; then
	export UP="✅"
	export DOWN="❌"
else
	export UP="Up"
	export DOWN="Down"
fi

speak() {
	if [[ $(uname) == 'Darwin' && ${GENV_SPEECH} == true ]]; then
		local speech=$(echo -e "$1" | sed 's/\n//g')
		say -v ${GENV_VOICE} -r ${GENV_SPEECH_RATE} "${speech}" &
	fi
}

speakGreeting() {
	if [[ -v GREETING && ! -v CI ]]; then
		export GENV_SPEECH_RATE=225
		if [ -x "$(command -v finger)" ]; then
			name=$(finger `whoami` | awk -F: '{ print $3 }' | head -n1 | sed 's/^ //' | cut -d " " -f 1)
		fi
		local msg="Hey ${name:-}! ${GREETING}"
		$(sleep 5 && speak "${msg}") &
		if [[ ${GENV_SPEECH} == false ]]; then
			echo -e "\n${COLOR_LIGHT_PURPLE}${msg}${COLOR_NC}\n"
		fi
	fi
}

printInfo() {
	echo -e "${COLOR_PURPLE}${1}${COLOR_NC}${2:-}"
}

# DEPRECATED
print_info() {
	printWarn "print_info() is deprecated. Please use printInfo()."
	printInfo "$1" "${2:-}"
}

speakInfo() {
	speak "$1"
	printInfo "$1" "${2:-}"
}

printSuccess() {
	echo -e "${COLOR_GREEN}${1}${COLOR_NC}${2:-}"
}

# DEPRECATED
print_success() {
	printWarn "print_success() is deprecated. Please use printSuccess()."
	printSuccess "$1" "${2:-}"
}

speakSuccess() {
	speak "$1"
	printSuccess "$1" "${2:-}"
}

printWarn() {
	echo -e "${COLOR_LIGHT_YELLOW}${1}${COLOR_NC}${2:-}"
}

# DEPRECATED
print_warn() {
	printWarn "print_warn() is deprecated. Please use printWarn()."
	printWarn "$1" "${2:-}"
}

printError() {
	echo -e "${COLOR_RED}${1}${COLOR_NC}${2:-}" >&2
}

printPanic() {
	printError "${1}" "${2:-}" >&2 && exit 1
}

printDebug() {
	if [ ${GENV_DEBUG:-} ]; then
		logDebug "$1"
		echo -e "${COLOR_DIM}${1}${COLOR_NC}" >&2
	fi
}

# DEPRECATED
print_debug() {
	printDebug "print_debug() is deprecated. Please use printDebug()."
	printDebug $1
}

logDebug() {
	if [ ${GENV_DEBUG:-} ]; then
		mkdir -p ${GENV_TEMP}
		echo -e "[$(date)] ${1}" >> ${GENV_TEMP}/debug.log
	fi
}

printUsage() {
	echo "Usage:"
	echo "  genv <command> [<arg>...]"
	echo "  genv -h|--help"
}
