#!/usr/bin/env bash

set -e

services() {
	for f in `ls ${SERVICES_ROOT}/${1}`; do
		if [[ "$f" = "services.sh" ]]; then
			continue
		fi
		echo -e "$f"
	done
}

# $1 service name
# $2 command
# $3 docker-compose file
handle_service() {
	source ${SERVICES_ROOT}/${1}/bootstrap.sh

	case "$2" in
		${1}:up)
			docker-compose ${3} up -d ${1}

			# execute service up hook
			if [ -n "$(type -t ${1}_up)" ] && [ "$(type -t ${1}_up)" = function ]; then ${1}_up; fi
			;;

		${1}:down)
			docker-compose ${3} down --rmi all -v

			# execute service down hook
			if [ -n "$(type -t ${1}_down)" ] && [ "$(type -t ${1}_down)" = function ]; then ${1}_down; fi
			;;

		${1}:kill)
			docker-compose ${3} kill ${1} ;;

		${1}:stop)
			docker-compose ${3} stop ${1} ;;

		${1}:start)
			docker-compose ${3} start ${1} ;;

		${1}:restart)
			docker-compose ${3} restart ${1} ;;

		${1}:rm)
			docker-compose ${3} rm ${args} ${1} ;;

		${1}:run)
			docker-compose run --rm ${args} ${1} ;;

		${1}:port)
			docker-compose ${3} port ${1} ${PRIVATE_PORT} ;;

		${1}:ps)
			docker-compose ${3} ps ${1} ;;

		${1}:logs)
			docker-compose ${3} logs ${args} ${1} ;;

		${1}:sh)
			docker-compose ${3} exec ${1} sh ;;

		${1}:help)
			echo "${1}:"
			HELP="
${1}:up) ## %% Create and start ${1} container(s)
${1}:down) ## %% Stop and remove ${1} container(s), image(s), and volume(s)
${1}:kill) ## %% Kill ${1}
${1}:stop) ## %% Stop ${1}
${1}:start) ## %% Start ${1}
${1}:restart) ## %% Restart ${1}
${1}:rm) ## %% Remove stopped ${1} container(s)
${1}:run) ## [<arg>...] %% Run a one-off command in the ${1} container
${1}:port) ## %% Print the public port for a port binding
${1}:ps) ## %% List ${1} container(s)
${1}:logs) ## %% View ${1} container output
${1}:sh) ## %% Enter a shell on the ${1} container
${1}) ## [<arg>...] %% Execute a command in the ${1} container
		"
			service_help "${HELP}"
			print_help ${SERVICES_ROOT}/${1}/handler.sh
			echo ""
			;;

		${1})
			docker-compose ${3} exec ${1} ${args} ;;
		${1}:*)
			SERVICE_COMPOSE_FILE=${3}
			source ${SERVICES_ROOT}/${1}/handler.sh
	esac
}

service_help() {
	help=$(echo -e "${1}" | grep -E '^[a-zA-Z:|_-]+\)\s##\s.*$' | sort | awk 'BEGIN {FS = "\\).*?## |%%"}; {c=$1" "$2; printf "\t\033[36m%-34s\033[0m%s\n", c, $3}')
	echo -e "$help"
}
