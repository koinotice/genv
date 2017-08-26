#!/usr/bin/env bash

# $1 service name
serviceExists() {
	if [ -d ${SERVICES_ROOT}/$1 ]; then
		export SERVICE_ROOT=${SERVICES_ROOT}/$1
	elif [ -d ${VENDOR_ROOT}/services/$1 ]; then
		export SERVICE_ROOT=${VENDOR_ROOT}/services/$1
	fi
}

# $1 service name
serviceBootstrap() {
	if [ -f ${SERVICE_ROOT}/bootstrap.sh ]; then
		source ${SERVICE_ROOT}/bootstrap.sh
	fi

	export COMPOSE_PROJECT_NAME=$1
	export DKR_COMPOSE_FILE="-f ${SERVICE_ROOT}/$1.yml"
	export DOCKER_COMPOSE_EXEC="${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} exec"

	if [ -v CI ]; then
		export DOCKER_COMPOSE_EXEC+=" -T"
	fi
}

listServices() {
	local services=""

	for f in $(ls ${SERVICES_ROOT}); do
		if [[ ${f} =~ services.sh|tasks.sh ]]; then
			continue
		fi

		local services+="$f\n"
	done

	if [ -d ${VENDOR_ROOT}/services ]; then
		for v in $(ls ${VENDOR_ROOT}/services); do
			local services+="$v\n"
		done
	fi

	echo -e "$services" | sort
}

# $1 service name
serviceStatus() {
	serviceExists $1

	if [ ! -v SERVICE_ROOT ]; then
		print_error "No such service $1"
		return
	fi

	serviceBootstrap $1

	local dockerComposePs="${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} ps"
	local serviceStatus="$(echo $1 | sed 's/-/_/g')_status"

	local isUp=$(${dockerComposePs} | grep Up > /dev/null && echo "true" || echo "false")

	if [[ "${isUp}" == "true" ]]; then
		printf "%-25s%s\n" "$1" "${UP}"
		export $serviceStatus='Up'
	else
		printf "%-25s%s\n" "$1" "${DOWN}"
		export $serviceStatus='Down'
	fi
}

# $1 service name
checkServiceStatus() {
	serviceStatus $1

	local serviceStatus="$(echo $1 | sed 's/-/_/g')_status"

	if [ ${!serviceStatus} == "Down" ]; then
		exit 1
	fi
}

servicesStatus() {
	for f in $(ls ${SERVICES_ROOT}); do
		if [[ ${f} =~ services.sh|tasks.sh ]]; then
			continue
		fi

		serviceStatus ${f}
	done

	if [ -d ${VENDOR_ROOT}/services ]; then
		for v in $(ls ${VENDOR_ROOT}/services); do
			serviceStatus ${v}
		done
	fi

	echo ""
}

# $1 service name
printServiceHelp() {
	printUsage
	echo "  harpoon <service-name>:<command> [<arg>...]"
	echo "  harpoon <service-name>:help"
	echo ""
	echo "Commands:"

	local helpTemplate="
$1:up) ## [options] [SERVICE...] %% 🔼️  Create and start $1 container(s)
$1:up-if-down) ## [options] [SERVICE...] %% ❔ 🔼️  If down, bring up
$1:down) ## [options] %% 🔽  Stop and remove $1 container(s)
$1:down-if-up) ## [options] %% ❔ 🔽  If up, take down
$1:destroy) ## %% 🔽  Stop and remove $1 container(s) and volume(s). Data will be ERASED! ⚠️
$1:destroy-if-up) ## %% ❔ 🔽  If up, destroy. Data will be ERASED! ⚠️
$1:clean) ## %% 🛀  Stop and remove $1 container(s), image(s), and volume(s). Data will be ERASED! ⚠️
$1:clean-if-up) ## %% ❔ 🛀  If up, clean. Data will be ERASED! ⚠️
$1:config) ## %% Display the docker-compose config for the $1 service
$1:kill) ## [options] [SERVICE...] %% ☠  Kill $1
$1:stop) ## [options] [SERVICE...] %% ⏹  Stop $1
$1:start) ## [SERVICE...] %% ▶️  Start $1
$1:restart) ## [options] [SERVICE...] %% 🔄  Restart $1 (Configuration is not reloaded)
$1:reset) ## %% 🌯  Bring down, removing volumes, and restart $1 containers. Data will be ERASED! ⚠️
$1:reset-if-up) ## %% 🌯  If up, reset. Data will be ERASED! ⚠️
$1:rm) ## [options] [SERVICE...] %% 🗑  Remove stopped $1 container(s)
$1:run) ## [options] [-v VOLUME...] [-p PORT...] [-e KEY=VAL...] SERVICE [COMMAND] [ARGS...] %% 🏃  Run a one-off command in a $1 container
$1:pause) ## [SERVICE...] %% ⏸  Pause $1
$1:unpause) ## [SERVICE...] %% ⏯  Unpause $1
$1:port:primary) ## %% Print the public port for the port binding of the primary $1 service
$1:port) ## [options] SERVICE PRIVATE_PORT %% Print the public port for a port binding
$1:ps) ## [options] [SERVICE...] %% 👓  List $1 container(s)
$1:logs) ## [options] [SERVICE...] %% 🖥  View $1 container output
$1:exec) ## [options] SERVICE COMMAND [ARGS...] %% 🏃‍♀️  Execute a command in a $1 container
$1:sh) ## SERVICE %% 🐚  Enter a shell on a $1 container
$1:status) ## %% 🚦  Display the status of the $1 service
	"

	local help=$(echo -e "${helpTemplate}" | grep -E '^[a-zA-Z0-9<>:|_-]+\)\s##\s.*$' | sort | awk 'BEGIN {FS = "\\).*?## |%%"}; {printf "  \033[36m%-25s\033[0m%-36s%s\n", $1, $2, $3}')
	echo -e "$help"
	echo ""
}

# $1 service name
serviceHelp() {
	serviceExists $1

	printServiceHelp $1

	if [ -f ${SERVICE_ROOT}/handler.sh ]; then
		printHelp ${SERVICE_ROOT}/handler.sh
		echo ""
	fi
}

# DEPRECATED
service_help() {
	printWarn "service_help() is deprecated. Please use serviceHelp()"
	serviceHelp $1
}

# $1 service name
# $2 docker-compose file
# $3 args
serviceUp() {
	printInfo "\n🔼  Bringing up $1..."

	${DOCKER_COMPOSE_CMD} $2 pull --ignore-pull-failures --parallel

	# execute service pre_up hook
	if [ -n "$(type -t ${1}_pre_up)" ] && [ "$(type -t ${1}_pre_up)" = function ]; then ${1}_pre_up "$2"; fi

	${DOCKER_COMPOSE_CMD} $2 up -d ${3:-}

	# execute service post_up hook
	if [ -n "$(type -t ${1}_post_up)" ] && [ "$(type -t ${1}_post_up)" = function ]; then ${1}_post_up "$2"; fi
}

# $1 service name
# $2 docker-compose file
# $3 args
serviceUpIfDown() {
	if ! SVC_STATUS=$(checkServiceStatus $1); then
		serviceUp $1 "$2" "${3:-}"
	fi
}

# $1 service name
# $2 docker-compose file
# $3 args
serviceDown() {
	printInfo "\n🔽  Taking down $1..."

	# execute service pre_down hook
	if [ -n "$(type -t ${1}_pre_down)" ] && [ "$(type -t ${1}_pre_down)" = function ]; then ${1}_pre_down "$2"; fi

	${DOCKER_COMPOSE_CMD} $2 down ${3:-}

	# execute service post_down hook
	if [ -n "$(type -t ${1}_post_down)" ] && [ "$(type -t ${1}_post_down)" = function ]; then ${1}_post_down "$2"; fi
}

# $1 service name
# $2 docker-compose file
# $3 args
serviceDownIfUp() {
	if SVC_STATUS=$(checkServiceStatus $1); then
		serviceDown $1 "$2" "${3:-}"
	fi
}

# $1 service name
# $2 docker-compose file
serviceReset() {
	printInfo "\n🌯  Resetting $1..."

	if [ -n "$(type -t ${1}_pre_reset)" ] && [ "$(type -t ${1}_pre_reset)" = function ]; then ${1}_pre_reset "$2"; fi

	serviceDown $1 "$2" "-v"
	serviceUp $1 "$2"

	if [ -n "$(type -t ${1}_post_reset)" ] && [ "$(type -t ${1}_post_reset)" = function ]; then ${1}_post_reset "$2"; fi
}

# $1 service name
# $2 docker-compose file
serviceResetIfUp() {
	if SVC_STATUS=$(checkServiceStatus $1); then
		serviceReset $1 "$2"
	fi
}

# $1 service name
# $2 docker-compose file
serviceDestroy() {
	printInfo "\n🔽  Destroying $1..."

	# execute service pre_down hook
	if [ -n "$(type -t ${1}_pre_destroy)" ] && [ "$(type -t ${1}_pre_destroy)" = function ]; then ${1}_pre_destroy "$2"; fi

	${DOCKER_COMPOSE_CMD} $2 down -v

	# execute service post_down hook
	if [ -n "$(type -t ${1}_post_destroy)" ] && [ "$(type -t ${1}_post_destroy)" = function ]; then ${1}_post_destroy "$2"; fi
}

# $1 service name
# $2 docker-compose file
serviceDestroyIfUp() {
	if SVC_STATUS=$(checkServiceStatus $1); then
		serviceDestroy $1 "$2"
	fi
}

# $1 service name
# $2 docker-compose file
serviceClean() {
	printInfo "\n🛀  Cleaning $1..."

	# execute service pre_clean hook
	if [ -n "$(type -t ${1}_pre_clean)" ] && [ "$(type -t ${1}_pre_clean)" = function ]; then ${1}_pre_clean "$2"; fi

	${DOCKER_COMPOSE_CMD} $2 down --rmi all -v

	# execute service post_clean hook
	if [ -n "$(type -t ${1}_post_clean)" ] && [ "$(type -t ${1}_post_clean)" = function ]; then ${1}_post_clean "$2"; fi
}

# $1 service name
# $2 docker-compose file
serviceCleanIfUp() {
	if SVC_STATUS=$(checkServiceStatus $1); then
		serviceClean $1 "$2"
	fi
}

# $1 service name
# $2 command
handleService() {
	if [[ "${firstArg:-}" == "--help" || "${firstArg:-}" == "-h" ]]; then
		subcmd=$(parseSubCmd ${command})

		dchelp=$(${DOCKER_COMPOSE_CMD} ${subcmd} -h 2>&1) || EXIT_CODE=$?

		if [ ! -v EXIT_CODE ]; then
			echo -e "${dchelp}"
		else
			serviceHelp $1 | grep ${subcmd}
		fi

		exit $?
	fi

	serviceBootstrap $1

	case "$2" in
		$1:up)
			serviceUp $1 "${DKR_COMPOSE_FILE}" "${args}" ;;

		$1:up-if-down)
			serviceUpIfDown $1 "${DKR_COMPOSE_FILE}" "${args}" ;;

		$1:down)
			serviceDown $1 "${DKR_COMPOSE_FILE}" "${args}" ;;

		$1:down-if-up)
			serviceDownIfUp $1 "${DKR_COMPOSE_FILE}" "${args}" ;;

		$1:reset)
			serviceReset $1 "${DKR_COMPOSE_FILE}" ;;

		$1:reset-if-up)
			serviceResetIfUp $1 "${DKR_COMPOSE_FILE}" ;;

		$1:destroy)
			serviceDestroy $1 "${DKR_COMPOSE_FILE}" ;;

		$1:destroy-if-up)
			serviceDestroyIfUp $1 "${DKR_COMPOSE_FILE}" ;;

		$1:clean)
			serviceClean $1 "${DKR_COMPOSE_FILE}" ;;

		$1:clean-if-up)
			serviceCleanIfUp $1 "${DKR_COMPOSE_FILE}" ;;

		$1:config)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} config ${args} ;;

		$1:kill)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} kill ${args} ;;

		$1:stop)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} stop ${args} ;;

		$1:start)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} start ${args} ;;

		$1:restart)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} restart ${args} ;;

		$1:rm)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} rm ${args} ;;

		$1:run)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} run ${args} ;;

		$1:pause)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} pause ${args} ;;

		$1:unpause)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} unpause ${args} ;;

		$1:port:primary)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} port $1 ${PRIVATE_PORT:-} ;;

		$1:port)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} port ${args} ;;

		$1:ps)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} ps ${args} ;;

		$1:logs)
			${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} logs ${args} ;;

		$1:status)
			checkServiceStatus $1 ;;

		$1:sh)
			${DOCKER_COMPOSE_EXEC} ${args} sh ;;

		$1:help)
			serviceHelp $1
			;;

		$1:exec)
			${DOCKER_COMPOSE_EXEC} ${args} ;;

		$1:*)
			if [ -f "${SERVICE_ROOT}/handler.sh" ]; then
				source "${SERVICE_ROOT}/handler.sh"
			else
				serviceHelp $1
			fi
	esac
}

# $1 name of services array
# $2 args
servicesUp() {
	local servicesArrayName="${1}[@]"
	for service in "${!servicesArrayName}"; do
		serviceExists ${service}

		if [ -v SERVICE_ROOT ]; then
			serviceBootstrap ${service}
			serviceUp ${service} "${DKR_COMPOSE_FILE}" "${2:-}"
		fi
	done
}

# $1 name of services array
# $2 args
servicesUpIfDown() {
	local servicesArrayName="${1}[@]"
	for service in "${!servicesArrayName}"; do
		serviceExists ${service}

		if [ -v SERVICE_ROOT ]; then
			serviceBootstrap ${service}
			serviceUpIfDown ${service} "${DKR_COMPOSE_FILE}" "${2:-}"
		fi
	done
}

# $1 name of services array
# $2 args
servicesDown() {
	local servicesArrayName="${1}[@]"
	for service in "${!servicesArrayName}"; do
		serviceExists ${service}

		if [ -v SERVICE_ROOT ]; then
			serviceBootstrap ${service}
			serviceDown ${service} "${DKR_COMPOSE_FILE}" "${2:-}"
		fi
	done
}

# $1 name of services array
# $2 args
servicesDownIfUp() {
	local servicesArrayName="${1}[@]"
	for service in "${!servicesArrayName}"; do
		serviceExists ${service}

		if [ -v SERVICE_ROOT ]; then
			serviceBootstrap ${service}
			serviceDownIfUp ${service} "${DKR_COMPOSE_FILE}" "${2:-}"
		fi
	done
}

# $services
servicesReset() {
	for service; do
		serviceExists ${service}

		if [ -v SERVICE_ROOT ]; then
			serviceBootstrap ${service}
			serviceReset ${service} "${DKR_COMPOSE_FILE}"
		fi
	done
}

# $services
servicesResetIfUp() {
	for service; do
		serviceExists ${service}

		if [ -v SERVICE_ROOT ]; then
			serviceBootstrap ${service}
			serviceResetIfUp ${service} "${DKR_COMPOSE_FILE}"
		fi
	done
}

# $services
servicesDestroy() {
	for service; do
		serviceExists ${service}

		if [ -v SERVICE_ROOT ]; then
			serviceBootstrap ${service}
			serviceDestroy ${service} "${DKR_COMPOSE_FILE}"
		fi
	done
}

# $services
servicesDestroyIfUp() {
	for service; do
		serviceExists ${service}

		if [ -v SERVICE_ROOT ]; then
			serviceBootstrap ${service}
			serviceDestroyIfUp ${service} "${DKR_COMPOSE_FILE}"
		fi
	done
}

# $services
servicesClean() {
	for service; do
		serviceExists ${service}

		if [ -v SERVICE_ROOT ]; then
			serviceBootstrap ${service}
			serviceClean ${service} "${DKR_COMPOSE_FILE}"
		fi
	done
}

# $services
servicesCleanIfUp() {
	for service; do
		serviceExists ${service}

		if [ -v SERVICE_ROOT ]; then
			serviceBootstrap ${service}
			serviceCleanIfUp ${service} "${DKR_COMPOSE_FILE}"
		fi
	done
}

# $services
partialServicesStatus() {
	for service; do
		serviceStatus ${service}
	done
}