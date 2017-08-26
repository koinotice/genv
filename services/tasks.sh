#!/usr/bin/env bash

case "${firstArg}" in
	list) ## %% 👓  List services available in Harpoon
		listServices ;;

	ls) ## %% Alias for `list`
		listServices ;;

	help)
		echo "Usage:"
		echo -e "  harpoon service <command> [<arg>...]\n"
		echo "Commands:"
		help=$(grep -E '^\s[a-zA-Z0-9:|_-]+\)\s##\s.*$' ${SERVICES_ROOT}/tasks.sh | sort | awk 'BEGIN {FS = "\\).*?## |%%"}; {gsub(/\t/,"  "); printf "\033[36m%-18s\033[0m%-20s%s\n", $1, $2, $3}')
		echo -e "$help"
		echo ""
		;;

	up) ## <service>... %% 🔼️  Create and start one or more services
		services=( "${@:3}" )
		servicesUp services ;;

	up-if-down) ## <service>... %% ❔ 🔼️  If down, bring up one or more services
		services=( "${@:3}" )
		servicesUpIfDown services ;;

	down) ## <service>... %% 🔽  Stop and remove one or more services
		services=( "${@:3}" )
		servicesDown services ;;

	down-if-up) ## <service>... %% ❔ 🔽  If up, take down one or more services
		services=( "${@:3}" )
		servicesDownIfUp services ;;

	reset) ## <service>... %% 🌯  Bring down, removing volumes, and restart one or more services. Data will be ERASED! ⚠️
		servicesReset "${@:3}" ;;

	reset-if-up) ## %% 🌯  If up, reset one or more services. Data will be ERASED! ⚠️
		servicesResetIfUp "${@:3}" ;;

	destroy) ## <service>... %% 🔽  Stop and remove one or more service container(s) and volume(s). Data will be ERASED! ⚠️
		servicesDestroy "${@:3}" ;;

	destroy-if-up) ## <service>... %% ❔ 🔽  If up, destroy one or more services. Data will be ERASED! ⚠️
		servicesDestroyIfUp "${@:3}" ;;

	clean) ## <service>... %% 🛀  Stop and remove one or more service container(s), image(s), and volume(s). Data will be ERASED! ⚠️
		servicesClean "${@:3}" ;;

	clean-if-up) ## <service>... %% ❔ 🛀  If up, clean one or more services. Data will be ERASED! ⚠️
		servicesCleanIfUp "${@:3}" ;;

	status) ## <service>... %% 🚦  Display the status of one or more services
		partialServicesStatus "${@:3}" ;;

	*)
		name=${2:-}
		serviceExists ${name}

		command="${name}:${3:-}"
		args=${@:4}

		handleService ${name} ${command}
esac

