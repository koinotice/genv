#!/usr/bin/env bash

set -e

services() {
	echo "mysql localstack"
}

# $1 service name
# $2 command
# $3 docker-compose file
handle_service() {
	source ${SERVICES_ROOT}/${1}/${1}.sh

	case "$2" in
		${1}:up)
			docker-compose ${3} up -d ${1}
			if [ -n "$(type -t ${1}_up)" ] && [ "$(type -t ${1}_up)" = function ]; then ${1}_up; fi
			;;

		${1}:down)
			docker-compose ${3} down --rmi all -v
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

		${1}:port)
			docker-compose ${3} port ${1} ${PRIVATE_PORT} ;;

		${1}:ps)
			docker-compose ${3} ps ${1} ;;

		${1}:logs)
			docker-compose ${3} logs ${args} ${1} ;;

		${1}:sh)
			docker-compose ${3} exec ${1} sh ;;

		${1}:help)
			for f in `ls ${SERVICES_ROOT}/${1}`; do
				if [[ $(echo ${f} | grep yml) ]]; then
					continue
				fi

				echo "${1}:"
		HELP="
${1}:up) ## %% Create and start ${1} container(s)
${1}:down) ## %% Stop and remove ${1} container(s), image(s), and volume(s)
${1}:kill) ## %% Kill ${1}
${1}:stop) ## %% Stop ${1}
${1}:start) ## %% Start ${1}
${1}:restart) ## %% Restart ${1}
${1}:rm) ## %% Remove stopped ${1} container(s)
${1}:port) ## %% Print the public port for a port binding
${1}:ps) ## %% List ${1} container(s)
${1}:logs) ## %% View ${1} container output
${1}:sh) ## %% Enter a shell on the ${1} container
${1}) ## [<arg>...] %% Execute a command in the ${1} container
		"
				service_help "${HELP}"
				print_help ${SERVICES_ROOT}/${1}/${f}
				echo ""
			done
			;;

		${1})
			docker-compose ${3} exec ${1} ${args} ;;
	esac
}