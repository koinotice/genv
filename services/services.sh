#!/usr/bin/env bash

# $1 service name
serviceRoot() {
	if [ -d ${HARPOON_SERVICES_ROOT}/$1 ]; then
		echo "${HARPOON_SERVICES_ROOT}/$1"
	elif [ -d ${HARPOON_VENDOR_ROOT}/services/$1 ]; then
		echo "${HARPOON_VENDOR_ROOT}/services/$1"
	fi
}

# $1 service name
serviceDockerCompose() {
	echo "${HARPOON_DOCKER_COMPOSE_CMD} -p $1 -f $(serviceRoot $1)/$1.yml"
}

# $1 service name
serviceDockerComposeExec() {
	local dockerComposeExec="$(serviceDockerCompose $1) exec"

	if [ -v CI ]; then
		dockerComposeExec+=" -T"
	fi

	echo ${dockerComposeExec}
}

# $1 service name
serviceBootstrap() {
	if [ -f $(serviceRoot $1)/bootstrap.sh ]; then
		printDebug "Bootstrapping $1..."
		source $(serviceRoot $1)/bootstrap.sh
	fi
}

listServices() {
	local services=""

	for f in $(ls ${HARPOON_SERVICES_ROOT}); do
		if [[ ${f} =~ services.sh|tasks.sh ]]; then
			continue
		fi

		local services+="$f\n"
	done

	if [ -d ${HARPOON_VENDOR_ROOT}/services ]; then
		for v in $(ls ${HARPOON_VENDOR_ROOT}/services); do
			local services+="$v\n"
		done
	fi

	echo -e "$services" | sort
}

# $1 service name
serviceStatus() {
	local svcRoot=$(serviceRoot $1)

	if [[ "$svcRoot" == "" ]]; then
		printPanic "No service named '$1'" " 😞"
	fi

	serviceBootstrap $1

	local serviceStatus="$(echo $1 | sed 's/-/_/g')_status"

	local isUp=$($(serviceDockerCompose $1) ps | grep Up > /dev/null && echo "true" || echo "false")

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
	for f in $(ls ${HARPOON_SERVICES_ROOT}); do
		if [[ ${f} =~ services.sh|tasks.sh ]]; then
			continue
		fi

		serviceStatus ${f}
	done

	if [ -d ${HARPOON_VENDOR_ROOT}/services ]; then
		for v in $(ls ${HARPOON_VENDOR_ROOT}/services); do
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
	local svcRoot=$(serviceRoot $1)

	if [[ "$svcRoot" == "" ]]; then
		printPanic "No service named $1" "😞"
	fi

	printServiceHelp $1

	if [ -f ${svcRoot}/handler.sh ]; then
		printHelp ${svcRoot}/handler.sh
		echo ""
	fi
}

# DEPRECATED
service_help() {
	printWarn "service_help() is deprecated. Please use serviceHelp()"
	serviceHelp $1
}

# $1 service name
# $2 args
serviceUp() {
	printInfo "\n🔼  Bringing up $1..."

	serviceBootstrap $1

	$(serviceDockerCompose $1) pull --ignore-pull-failures --parallel

	# execute service pre_up hook
	if [ -n "$(type -t ${1}_pre_up)" ] && [ "$(type -t ${1}_pre_up)" = function ]; then ${1}_pre_up $1; fi

	$(serviceDockerCompose $1) up -d ${2:-}

	# execute service post_up hook
	if [ -n "$(type -t ${1}_post_up)" ] && [ "$(type -t ${1}_post_up)" = function ]; then ${1}_post_up $1; fi
}

# $1 service name
# $2 args
serviceUpIfDown() {
	if ! svcStatus=$(checkServiceStatus $1); then
		serviceUp $1 "${2:-}"
	fi
}

# $1 service name
# $2 args
serviceDown() {
	printInfo "\n🔽  Taking down $1..."

	serviceBootstrap $1

	# execute service pre_down hook
	if [ -n "$(type -t ${1}_pre_down)" ] && [ "$(type -t ${1}_pre_down)" = function ]; then ${1}_pre_down $1; fi

	$(serviceDockerCompose $1) down ${2:-}

	# execute service post_down hook
	if [ -n "$(type -t ${1}_post_down)" ] && [ "$(type -t ${1}_post_down)" = function ]; then ${1}_post_down $1; fi
}

# $1 service name
# $2 args
serviceDownIfUp() {
	if svcStatus=$(checkServiceStatus $1); then
		serviceDown $1 "${2:-}"
	fi
}

# $1 service name
serviceReset() {
	printInfo "\n🌯  Resetting $1..."

	serviceBootstrap $1

	if [ -n "$(type -t ${1}_pre_reset)" ] && [ "$(type -t ${1}_pre_reset)" = function ]; then ${1}_pre_reset $1; fi

	serviceDown $1 "-v"
	serviceUp $1

	if [ -n "$(type -t ${1}_post_reset)" ] && [ "$(type -t ${1}_post_reset)" = function ]; then ${1}_post_reset $1; fi
}

# $1 service name
serviceResetIfUp() {
	if svcStatus=$(checkServiceStatus $1); then
		serviceReset $1
	fi
}

# $1 service name
serviceDestroy() {
	printInfo "\n🗑  Destroying $1..."

	serviceBootstrap $1

	# execute service pre_down hook
	if [ -n "$(type -t ${1}_pre_destroy)" ] && [ "$(type -t ${1}_pre_destroy)" = function ]; then ${1}_pre_destroy $1; fi

	$(serviceDockerCompose $1) down -v

	# execute service post_down hook
	if [ -n "$(type -t ${1}_post_destroy)" ] && [ "$(type -t ${1}_post_destroy)" = function ]; then ${1}_post_destroy $1; fi
}

# $1 service name
serviceDestroyIfUp() {
	if svcStatus=$(checkServiceStatus $1); then
		serviceDestroy $1
	fi
}

# $1 service name
serviceClean() {
	printInfo "\n🛀  Cleaning $1..."

	serviceBootstrap $1

	# execute service pre_clean hook
	if [ -n "$(type -t ${1}_pre_clean)" ] && [ "$(type -t ${1}_pre_clean)" = function ]; then ${1}_pre_clean $1; fi

	$(serviceDockerCompose $1) down --rmi all -v

	# execute service post_clean hook
	if [ -n "$(type -t ${1}_post_clean)" ] && [ "$(type -t ${1}_post_clean)" = function ]; then ${1}_post_clean $1; fi
}

# $1 service name
serviceCleanIfUp() {
	if svcStatus=$(checkServiceStatus $1); then
		serviceClean $1
	fi
}

# $1 service name
# $2 args
serviceConfig() {
	serviceBootstrap $1
	$(serviceDockerCompose $1) config $2
}

# $1 service name
# $2 args
serviceKill() {
	serviceBootstrap $1
	$(serviceDockerCompose $1) kill $2
}

# $1 service name
# $2 args
serviceStop() {
	serviceBootstrap $1
	$(serviceDockerCompose $1) stop $2
}

# $1 service name
# $2 args
serviceStart() {
	serviceBootstrap $1
	$(serviceDockerCompose $1) start $2
}

# $1 service name
# $2 args
serviceRestart() {
	serviceBootstrap $1
	$(serviceDockerCompose $1) restart $2
}

# $1 service name
# $2 args
serviceRm() {
	serviceBootstrap $1
	$(serviceDockerCompose $1) rm $2
}

# $1 service name
# $2 args
serviceRun() {
	serviceBootstrap $1
	$(serviceDockerCompose $1) run $2
}

# $1 service name
# $2 args
servicePause() {
	serviceBootstrap $1
	$(serviceDockerCompose $1) pause $2
}

# $1 service name
# $2 args
serviceUnpause() {
	serviceBootstrap $1
	$(serviceDockerCompose $1) unpause $2
}

# $1 service name
# $2 args
servicePort() {
	serviceBootstrap $1
	$(serviceDockerCompose $1) port $2
}

# $1 service name
# $2 args
servicePs() {
	serviceBootstrap $1
	$(serviceDockerCompose $1) ps $2
}

# $1 service name
# $2 args
serviceLogs() {
	serviceBootstrap $1
	$(serviceDockerCompose $1) logs $2
}

# $1 service name
# $2 args
serviceExec() {
	serviceBootstrap $1
	$(serviceDockerCompose $1) exec $2
}

# $1 service name
# $2 command
handleService() {
	if [[ "${firstArg:-}" == "--help" || "${firstArg:-}" == "-h" ]]; then
		subcmd=$(parseSubCmd ${command})

		dchelp=$($(serviceDockerCompose $1) ${subcmd} -h 2>&1) || EXIT_CODE=$?

		if [ ! -v EXIT_CODE ]; then
			echo -e "${dchelp}"
		else
			serviceHelp $1 | grep ${subcmd}
		fi

		exit $?
	fi

	case "$2" in
		$1:up)
			serviceUp $1 "${args}" ;;

		$1:up-if-down)
			serviceUpIfDown $1 "${args}" ;;

		$1:down)
			serviceDown $1 "${args}" ;;

		$1:down-if-up)
			serviceDownIfUp $1 "${args}" ;;

		$1:reset)
			serviceReset $1 ;;

		$1:reset-if-up)
			serviceResetIfUp $1 ;;

		$1:destroy)
			serviceDestroy $1 ;;

		$1:destroy-if-up)
			serviceDestroyIfUp $1 ;;

		$1:clean)
			serviceClean $1 ;;

		$1:clean-if-up)
			serviceCleanIfUp $1 ;;

		$1:config)
			serviceConfig $1 "${args}" ;;

		$1:kill)
			serviceKill $1 "${args}" ;;

		$1:stop)
			serviceStop $1 "${args}" ;;

		$1:start)
			serviceStart $1 "${args}" ;;

		$1:restart)
			serviceRestart $1 "${args}" ;;

		$1:rm)
			serviceRm $1 "${args}" ;;

		$1:run)
			serviceRun $1 "${args}" ;;

		$1:pause)
			servicePause $1 "${args}" ;;

		$1:unpause)
			serviceUnpause $1 "${args} ";;

		$1:port)
			servicePort $1 "${args}" ;;

		$1:ps)
			servicePs $1 "${args}" ;;

		$1:logs)
			serviceLogs $1 "${args}" ;;

		$1:status)
			checkServiceStatus $1 ;;

		$1:sh)
			serviceBootstrap $1
			$(serviceDockerComposeExec $1) ${args} sh
			;;

		$1:help)
			serviceHelp $1 ;;

		$1:exec)
			serviceExec $1 "${args}" ;;

		$1:*)
			svcRoot=$(serviceRoot $1)

			if [[ "$svcRoot" == "" ]]; then
				printPanic "No service named $1" "😞"
			fi

			serviceBootstrap $1

			if [ -f ${svcRoot}/handler.sh ]; then
				source ${svcRoot}/handler.sh
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
		serviceUp ${service} "${2:-}"
	done
}

# $1 name of services array
# $2 args
servicesUpIfDown() {
	local servicesArrayName="${1}[@]"
	for service in "${!servicesArrayName}"; do
		serviceUpIfDown ${service} "${2:-}"
	done
}

# $1 name of services array
# $2 args
servicesDown() {
	local servicesArrayName="${1}[@]"
	for service in "${!servicesArrayName}"; do
		serviceDown ${service} "${2:-}"
	done
}

# $1 name of services array
# $2 args
servicesDownIfUp() {
	local servicesArrayName="${1}[@]"
	for service in "${!servicesArrayName}"; do
		serviceDownIfUp ${service} "${2:-}"
	done
}

# $1 name of services array
servicesReset() {
	local servicesArrayName="${1}[@]"
	for service in "${!servicesArrayName}"; do
		serviceReset ${service}
	done
}

# $1 name of services array
servicesResetIfUp() {
	local servicesArrayName="${1}[@]"
	for service in "${!servicesArrayName}"; do
		serviceResetIfUp ${service}
	done
}

# $1 name of services array
servicesDestroy() {
	local servicesArrayName="${1}[@]"
	for service in "${!servicesArrayName}"; do
		serviceDestroy ${service}
	done
}

# $1 name of services array
servicesDestroyIfUp() {
	local servicesArrayName="${1}[@]"
	for service in "${!servicesArrayName}"; do
		serviceDestroyIfUp ${service}
	done
}

# $1 name of services array
servicesClean() {
	local servicesArrayName="${1}[@]"
	for service in "${!servicesArrayName}"; do
		serviceClean ${service}
	done
}

# $1 name of services array
servicesCleanIfUp() {
	local servicesArrayName="${1}[@]"
	for service in "${!servicesArrayName}"; do
		serviceCleanIfUp ${service}
	done
}

# # $1 name of services array
partialServicesStatus() {
	local servicesArrayName="${1}[@]"
	for service in "${!servicesArrayName}"; do
		serviceStatus ${service}
	done
}