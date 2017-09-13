#!/usr/bin/env bash

serviceUsage() {
	echo "Usage:"
	echo -e "  harpoon service <command> [<arg>...]\n"
	echo "Commands:"
	help=$(grep -E '^\s[a-zA-Z0-9:|_-]+\)\s##\s.*$' ${HARPOON_SERVICES_ROOT}/tasks.sh | sort | awk 'BEGIN {FS = "\\).*?## |%%"}; {gsub(/\t/,"  "); printf "\033[36m%-18s\033[0m%-20s%s\n", $1, $2, $3}')
	echo -e "$help"
	echo ""
}

case "${firstArg}" in
	list) ## %% 👓  List services available in Harpoon
		listServices ;;

	ls) ## %% Alias for `list`
		listServices ;;

	env:doc) ## [<service>] %% List available/exported environment variables
		svcRoot=$(serviceRoot ${@:3})

		if [[ "$svcRoot" != "" ]]; then
			printModuleInfo "${svcRoot}/info.txt" "${@:3}"
			printEnv ${svcRoot}
		fi
		;;

	help) ## [<service>] %% ⁉️  Get help
		if [[ "${@:3}" != "" ]]; then
			serviceHelp ${@:3}
		else
			serviceUsage
		fi
		;;

	--help|-h)
		serviceUsage ;;

	up) ## <service>... %% 🔼️  Create and start one or more services
		services=( "${@:3}" )
		servicesUp services
		;;

	up-if-down) ## <service>... %% ❔ 🔼️  If down, bring up one or more services
		services=( "${@:3}" )
		servicesUpIfDown services
		;;

	down) ## <service>... %% 🔽  Stop and remove one or more services
		services=( "${@:3}" )
		servicesDown services
		;;

	down-if-up) ## <service>... %% ❔ 🔽  If up, take down one or more services
		services=( "${@:3}" )
		servicesDownIfUp services
		;;

	reset) ## <service>... %% 🌯  Bring down, removing volumes, and restart one or more services. Data will be ERASED! ⚠️
		services=( "${@:3}" )
		servicesReset services
		;;

	reset-if-up) ## %% 🌯  If up, reset one or more services. Data will be ERASED! ⚠️
		services=( "${@:3}" )
		servicesResetIfUp services
		;;

	destroy) ## <service>... %% 🔽  Stop and remove one or more service container(s) and volume(s). Data will be ERASED! ⚠️
		services=( "${@:3}" )
		servicesDestroy services
		;;

	destroy-if-up) ## <service>... %% ❔ 🔽  If up, destroy one or more services. Data will be ERASED! ⚠️
		services=( "${@:3}" )
		servicesDestroyIfUp services
		;;

	clean) ## <service>... %% 🛀  Stop and remove one or more service container(s), image(s), and volume(s). Data will be ERASED! ⚠️
		services=( "${@:3}" )
		servicesClean services
		;;

	clean-if-up) ## <service>... %% ❔ 🛀  If up, clean one or more services. Data will be ERASED! ⚠️
		services=( "${@:3}" )
		servicesCleanIfUp services
		;;

	status) ## <service>... %% 🚦  Display the status of one or more services
		services=( "${@:3}" )
		partialServicesStatus services
		;;

	*)
		name=${2:-}

		if [[ "$name" == "" ]]; then
			serviceUsage
			exit 1
		fi

		command="${name}:${3:-}"
		args=${@:4}

		handleService ${name} ${command}
esac

