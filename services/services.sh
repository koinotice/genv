#!/usr/bin/env bash

set -euo pipefail

service_docker_compose_file() {
	echo "-f ${HARPOON_ROOT}/services/${1}/${1}.yml"
}

services() {
	for f in `ls ${SERVICES_ROOT}/${1:-}`; do
		if [[ "$f" = "services.sh" ]]; then
			continue
		fi
		echo -e "$f"
	done
}

services_status() {
	for f in `ls ${SERVICES_ROOT}/${1:-}`; do
		if [[ "$f" = "services.sh" ]]; then
			continue
		fi
		DKR_COMPOSE_FILE=$(service_docker_compose_file ${f})
		source ${SERVICES_ROOT}/${f}/bootstrap.sh
		IS_UP=$(docker-compose ${DKR_COMPOSE_FILE} ps | grep 'Up') || true
		if [[ ${IS_UP} ]]; then
			printf "%-15s%s\n" "${f}" 'Up'
		else
			printf "%-15s%s\n" "${f}" 'Down'
		fi
	done
	echo ""
}

service_help() {
	HELP="
${1}:up) ## [options] [SERVICE...] %% Create and start ${1} container(s)
${1}:down) ## [options] %% Stop and remove ${1} container(s), image(s), and volume(s)
${1}:kill) ## [options] [SERVICE...] %% Kill ${1}
${1}:stop) ## [options] [SERVICE...] %% Stop ${1}
${1}:start) ## [SERVICE...] %% Start ${1}
${1}:restart) ## [options] [SERVICE...] %% Restart ${1}
${1}:reset) ## %% Stop, Remove, and Restart ${1} container(s)
${1}:rm) ## [options] [SERVICE...] %% Remove stopped ${1} container(s)
${1}:run) ## [options] [-v VOLUME...] [-p PORT...] [-e KEY=VAL...] SERVICE [COMMAND] [ARGS...] %% Run a one-off command in a ${1} container
${1}:port:primary) ## %% Print the public port for the port binding of the primary ${1} service
${1}:port) ## [options] SERVICE PRIVATE_PORT %% Print the public port for a port binding
${1}:ps) ## [options] [SERVICE...] %% List ${1} container(s)
${1}:logs) ## [options] [SERVICE...] %% View ${1} container output
${1}:exec) ## [options] SERVICE COMMAND [ARGS...] %% Execute a command in a ${1} container
${1}:sh) ## <docker-compose-service-name> %% Enter a shell on a ${1} container
	"

#	help=$(echo -e "${1}" | grep -E '^[a-zA-Z:|_-]+\)\s##\s.*$' | sort | awk 'BEGIN {FS = "\\).*?## |%%"}; {c=$1" "$2; printf "\t\033[36m%-34s\033[0m%s\n", c, $3}')
	help=$(echo -e "${HELP}" | grep -E '^[a-zA-Z:|_-]+\)\s##\s.*$' | sort | awk 'BEGIN {FS = "\\).*?## |%%"}; {printf "  \033[36m%-25s\033[0m%-36s%s\n", $1, $2, $3}')
	echo -e "$help"
	echo ""
	print_help ${SERVICES_ROOT}/${1}/handler.sh
	echo ""
}


# $1 service name
# $2 command
# $3 docker-compose file
handle_service() {
	DKR_COMPOSE_FILE=$(service_docker_compose_file ${1})
	source ${SERVICES_ROOT}/${1:-}/bootstrap.sh

	case "$2" in
		${1}:up)
			docker-compose ${DKR_COMPOSE_FILE} up -d ${args}

			# execute service up hook
			if [ -n "$(type -t ${1}_up)" ] && [ "$(type -t ${1}_up)" = function ]; then ${1}_up "${DKR_COMPOSE_FILE}"; fi
			;;

		${1}:down|${1}:clean)
			docker-compose ${DKR_COMPOSE_FILE} down ${args} --rmi all -v

			# execute service down hook
			if [ -n "$(type -t ${1}_down)" ] && [ "$(type -t ${1}_down)" = function ]; then ${1}_down "${DKR_COMPOSE_FILE}"; fi
			;;

		${1}:kill)
			docker-compose ${DKR_COMPOSE_FILE} kill ${args} ;;

		${1}:stop)
			docker-compose ${DKR_COMPOSE_FILE} stop ${args} ;;

		${1}:start)
			docker-compose ${DKR_COMPOSE_FILE} start ${args} ;;

		${1}:restart)
			docker-compose ${DKR_COMPOSE_FILE} restart ${args} ;;

		${1}:reset)
			docker-compose ${DKR_COMPOSE_FILE} stop
			docker-compose ${DKR_COMPOSE_FILE} rm -f -v
			docker-compose ${DKR_COMPOSE_FILE} up -d
			;;

		${1}:rm)
			docker-compose ${DKR_COMPOSE_FILE} rm ${args} ;;

		${1}:run)
			docker-compose ${DKR_COMPOSE_FILE} run ${args} ;;

		${1}:port:primary)
			docker-compose ${DKR_COMPOSE_FILE} port ${1} ${PRIVATE_PORT:-} ;;

		${1}:port)
			docker-compose ${DKR_COMPOSE_FILE} port ${args} ;;

		${1}:ps|${1}:status)
			docker-compose ${DKR_COMPOSE_FILE} ps ${args} ;;

		${1}:logs)
			docker-compose ${DKR_COMPOSE_FILE} logs ${args} ;;

		${1}:sh)
			docker-compose ${DKR_COMPOSE_FILE} exec ${args} sh ;;

		${1}:help)
			echo "${1}:"
			service_help ${1}
			;;

		${1}:exec)
			docker-compose ${DKR_COMPOSE_FILE} exec ${args} ;;

		${1}:*)
			source ${SERVICES_ROOT}/${1}/handler.sh
	esac
}

