#!/usr/bin/env bash

set -euo pipefail

# $1 service name
service_exists() {
	if [ -d ${SERVICES_ROOT}/${1} ]; then
		export SERVICE_ROOT=${SERVICES_ROOT}/${1}
	elif [ -d ${SERVICES_ROOT}/custom/${1} ]; then
		export SERVICE_ROOT=${SERVICES_ROOT}/custom/${1}
	else
		echo -e "\nNo service named '${1}' was found."
		exit 1
	fi
}

source_bootstrap() {
	source ${SERVICE_ROOT}/bootstrap.sh
}

services() {
	for f in `ls ${SERVICES_ROOT}/${1:-}`; do
		if [[ "$f" = "services.sh" ]]; then
			continue
		fi

		if [[ "$f" = "custom" ]]; then
			for f in `ls ${SERVICES_ROOT}/custom/${1:-}`; do
				echo -e "$f"
			done
			continue
		fi

		echo -e "$f"
	done
}

# $1 service name
service_status() {
	service_exists ${1}

	source_bootstrap

	SERVICE_STATUS="$(echo $1 | sed 's/-/_/g')_status"

	IS_UP=$(${DOCKER_COMPOSE_CMD} -f ${SERVICE_ROOT}/${1}.yml ps | grep 'Up') || true
	if [[ ${IS_UP} ]]; then
		printf "%-15s%s\n" "${1}" 'Up'
		export $SERVICE_STATUS='Up'
	else
		printf "%-15s%s\n" "${1}" 'Down'
		export $SERVICE_STATUS='Down'
	fi
}

check_service_status() {
	service_status ${1}
	SERVICE_STATUS="$(echo $1 | sed 's/-/_/g')_status"
	if [ ${!SERVICE_STATUS} == "Down" ]; then
		exit 1
	fi
}

services_status() {
	for f in `ls ${SERVICES_ROOT}/${1:-}`; do
		if [[ "$f" = "services.sh" ]]; then
			continue
		fi

		if [[ "$f" = "custom" ]]; then
			for f in `ls ${SERVICES_ROOT}/custom/${1:-}`; do
				service_status ${f}
			done
			continue
		fi

		service_status ${f}
	done
	echo ""
}

service_help() {
	service_exists ${1}

	HELP="
${1}:up) ## [options] [SERVICE...] %% 🔼️  Create and start ${1} container(s)
${1}:up-if-down) ## [options] [SERVICE...] %% ❔ 🔼️  If down, bring up
${1}:down) ## [options] %% 🔽  Stop and remove ${1} container(s)
${1}:down-if-up) ## [options] %% ❔ 🔽  If up, bring down
${1}:destroy) ## [options] %% 🔽  Stop and remove ${1} container(s) and volume(s). Data will be ERASED! ⚠
${1}:destroy-if-up) ## [options] %% ❔ 🔽  If up, destroy. Data will be ERASED! ⚠
${1}:clean) ## %% 🛀  Stop and remove ${1} container(s), image(s), and volume(s). Data will be ERASED! ⚠️
${1}:clean-if-up) ## %% ❔ 🛀  If up, clean. Data will be ERASED! ⚠️
${1}:kill) ## [options] [SERVICE...] %% ☠  Kill ${1}
${1}:stop) ## [options] [SERVICE...] %% ⏹  Stop ${1}
${1}:start) ## [SERVICE...] %% ▶️  Start ${1}
${1}:restart) ## [options] [SERVICE...] %% 🔄  Restart ${1} (Configuration is not reloaded)
${1}:reset) ## %% 🌯  Bring down, removing volumes, and restart ${1} containers. Data will be ERASED! ⚠️
${1}:rm) ## [options] [SERVICE...] %% 🗑  Remove stopped ${1} container(s)
${1}:run) ## [options] [-v VOLUME...] [-p PORT...] [-e KEY=VAL...] SERVICE [COMMAND] [ARGS...] %% 🏃  Run a one-off command in a ${1} container
${1}:pause) ## [SERVICE...] %% ⏸  Pause ${1}
${1}:unpause) ## [SERVICE...] %% ⏯  Unpause ${1}
${1}:port:primary) ## %% Print the public port for the port binding of the primary ${1} service
${1}:port) ## [options] SERVICE PRIVATE_PORT %% Print the public port for a port binding
${1}:ps) ## [options] [SERVICE...] %% 👓  List ${1} container(s)
${1}:logs) ## [options] [SERVICE...] %% 🖥  View ${1} container output
${1}:exec) ## [options] SERVICE COMMAND [ARGS...] %% 🏃‍♀️  Execute a command in a ${1} container
${1}:sh) ## SERVICE %% 🐚  Enter a shell on a ${1} container
${1}:status) ## %% 🚦  Display the status of the ${1} service
	"

#	help=$(echo -e "${1}" | grep -E '^[a-zA-Z:|_-]+\)\s##\s.*$' | sort | awk 'BEGIN {FS = "\\).*?## |%%"}; {c=$1" "$2; printf "\t\033[36m%-34s\033[0m%s\n", c, $3}')
	help=$(echo -e "${HELP}" | grep -E '^[a-zA-Z:|_-]+\)\s##\s.*$' | sort | awk 'BEGIN {FS = "\\).*?## |%%"}; {printf "  \033[36m%-25s\033[0m%-36s%s\n", $1, $2, $3}')
	echo -e "$help"
	echo ""
	print_help ${SERVICE_ROOT}/handler.sh
	echo ""
}

# $1 service name
# $2 docker-compose file name
# $3 args
service_up() {
	# execute service pre_up hook
	if [ -n "$(type -t ${1}_pre_up)" ] && [ "$(type -t ${1}_pre_up)" = function ]; then ${1}_pre_up "${2}"; fi

	${DOCKER_COMPOSE_CMD} ${2} up -d ${3:-}

	# execute service post_up hook
	if [ -n "$(type -t ${1}_post_up)" ] && [ "$(type -t ${1}_post_up)" = function ]; then ${1}_post_up "${2}"; fi
}

# $1 service name
# $2 docker-compose file name
# $3 args
service_down() {
	# execute service pre_down hook
	if [ -n "$(type -t ${1}_pre_down)" ] && [ "$(type -t ${1}_pre_down)" = function ]; then ${1}_pre_down "${2}"; fi

	${DOCKER_COMPOSE_CMD} ${2} down ${3:-}

	# execute service post_down hook
	if [ -n "$(type -t ${1}_post_down)" ] && [ "$(type -t ${1}_post_down)" = function ]; then ${1}_post_down "${2}"; fi
}

# $1 service name
# $2 docker-compose file name
service_destroy() {
	# execute service pre_down hook
	if [ -n "$(type -t ${1}_pre_destroy)" ] && [ "$(type -t ${1}_pre_destroy)" = function ]; then ${1}_pre_destroy "${2}"; fi

	${DOCKER_COMPOSE_CMD} ${2} down -v

	# execute service post_down hook
	if [ -n "$(type -t ${1}_post_destroy)" ] && [ "$(type -t ${1}_post_destroy)" = function ]; then ${1}_post_destroy "${2}"; fi
}

# $1 service name
# $2 docker-compose file name
service_clean() {
	# execute service pre_clean hook
	if [ -n "$(type -t ${1}_pre_clean)" ] && [ "$(type -t ${1}_pre_clean)" = function ]; then ${1}_pre_clean "${2}"; fi

	${DOCKER_COMPOSE_CMD} ${2} down --rmi all -v

	# execute service post_clean hook
	if [ -n "$(type -t ${1}_post_clean)" ] && [ "$(type -t ${1}_post_clean)" = function ]; then ${1}_post_clean "${2}"; fi
}


# $1 service name
# $2 command
handle_service() {
	service_exists ${1}

	DKR_COMPOSE_FILE="-f ${SERVICE_ROOT}/${1}.yml"

	source_bootstrap

	case "$2" in
		${1}:up)
			service_up ${1} "${DKR_COMPOSE_FILE}" "${args}" ;;

		${1}:up-if-down)
			if ! SVC_STATUS=$(check_service_status ${1}); then
				service_up ${1} "${DKR_COMPOSE_FILE}" "${args}"
			fi
			;;

		${1}:down)
			service_down ${1} "${DKR_COMPOSE_FILE}" "${args}" ;;

		${1}:down-if-up)
			if SVC_STATUS=$(check_service_status ${1}); then
				service_down ${1} "${DKR_COMPOSE_FILE}" "${args}"
			fi
			;;

		${1}:destroy)
			service_destroy ${1} "${DKR_COMPOSE_FILE}" ;;

		${1}:destroy-if-up)
			if SVC_STATUS=$(check_service_status ${1}); then
				service_destroy ${1} "${DKR_COMPOSE_FILE}"
			fi
			;;

		${1}:clean)
			service_clean ${1} "${DKR_COMPOSE_FILE}" ;;

		${1}:clean-if-up)
			if SVC_STATUS=$(check_service_status ${1}); then
				service_clean ${1} "${DKR_COMPOSE_FILE}"
			fi
			;;

		${1}:kill)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} kill ${args} ;;

		${1}:stop)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} stop ${args} ;;

		${1}:start)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} start ${args} ;;

		${1}:restart)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} restart ${args} ;;

		${1}:reset)
			if [ -n "$(type -t ${1}_pre_reset)" ] && [ "$(type -t ${1}_pre_reset)" = function ]; then ${1}_pre_reset "${DKR_COMPOSE_FILE}"; fi

			service_down ${1} "${DKR_COMPOSE_FILE}" "-v"
			service_up ${1} "${DKR_COMPOSE_FILE}"

			if [ -n "$(type -t ${1}_post_reset)" ] && [ "$(type -t ${1}_post_reset)" = function ]; then ${1}_post_reset "${DKR_COMPOSE_FILE}"; fi
			;;

		${1}:rm)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} rm ${args} ;;

		${1}:run)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} run ${args} ;;

		${1}:pause)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} pause ${args} ;;

		${1}:unpause)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} unpause ${args} ;;

		${1}:port:primary)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} port ${1} ${PRIVATE_PORT:-} ;;

		${1}:port)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} port ${args} ;;

		${1}:ps)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} ps ${args} ;;

		${1}:logs)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} logs ${args} ;;

		${1}:status)
			check_service_status ${1} ;;

		${1}:sh)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} exec ${args} sh ;;

		${1}:help)
			echo "${1}:"
			service_help ${1}
			;;

		${1}:exec)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} exec ${args} ;;

		${1}:*)
			source "${SERVICE_ROOT}/handler.sh"
	esac
}

