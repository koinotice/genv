#!/usr/bin/env bash

print_help() {
	help=$(grep -E '^\t[a-zA-Z:|_-]+\)\s##\s.*$' ${1} | sort | awk 'BEGIN {FS = "\\).*?## |%%"}; {c=$1" "$2; printf "\033[36m%-34s\033[0m %s\n", c, $3}')
	echo -e "$help"
}

service_help() {
	help=$(echo -e "${1}" | grep -E '^[a-zA-Z:|_-]+\)\s##\s.*$' | sort | awk 'BEGIN {FS = "\\).*?## |%%"}; {c=$1" "$2; printf "\t\033[36m%-34s\033[0m %s\n", c, $3}')
	echo -e "$help"
}
