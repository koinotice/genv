#!/usr/bin/env bash

serviceUsage() {
	echo "Usage:"
	echo -e "  genv service <command> [<arg>...]\n"
	echo "Commands:"
	help=$(grep -E '^\s[a-zA-Z0-9:|_-]+\)\s##\s.*$' ${GENV_SERVICES_ROOT}/tasks.sh | sort | awk 'BEGIN {FS = "\\).*?## |%%"}; {gsub(/\t/,"  "); printf "\033[36m%-18s\033[0m%-20s%s\n", $1, $2, $3}')
	echo -e "$help"
	echo ""
}

if [[ "${#args_array[@]}" -gt 1 ]]; then
	services=( "${args_array[@]:1}" )
fi

case "${firstArg}" in
	list) ## %% 👓  List services available in Genv
		listServices ;;

	ls) ## %% Alias for `list`
		listServices ;;

	env:doc) ## [<service>] %% List available/exported environment variables
		svcRoot=$(serviceRoot ${services[@]})

		if [[ "$svcRoot" != "" ]]; then
			printModuleInfo "${svcRoot}/info.txt" "${services[@]}"
			printEnv ${svcRoot}
		fi
		;;

	help) ## [<service>] %% ⁉️  Get help
		if [[ "${services[1]:-}" != "" ]]; then
			serviceHelp ${services[@]}
		else
			serviceUsage
		fi
		;;

	--help|-h)
		serviceUsage ;;

	up) ## <service>... %% 🔼️  Create and start one or more services
		servicesUp services
		;;

	up-if-down) ## <service>... %% ❔ 🔼️  If down, bring up one or more services
		servicesUpIfDown services
		;;

	down) ## <service>... %% 🔽  Stop and remove one or more services
		servicesDown services
		;;

	down-if-up) ## <service>... %% ❔ 🔽  If up, take down one or more services
		servicesDownIfUp services
		;;

	reset) ## <service>... %% 🌯  Bring down, removing volumes, and restart one or more services. Data will be ERASED! ⚠️
		servicesReset services
		;;

	reset-if-up) ## %% 🌯  If up, reset one or more services. Data will be ERASED! ⚠️
		servicesResetIfUp services
		;;

	destroy) ## <service>... %% 🔽  Stop and remove one or more service container(s) and volume(s). Data will be ERASED! ⚠️
		servicesDestroy services
		;;

	destroy-if-up) ## <service>... %% ❔ 🔽  If up, destroy one or more services. Data will be ERASED! ⚠️
		servicesDestroyIfUp services
		;;

	clean) ## <service>... %% 🛀  Stop and remove one or more service container(s), image(s), and volume(s). Data will be ERASED! ⚠️
		servicesClean services
		;;

	clean-if-up) ## <service>... %% ❔ 🛀  If up, clean one or more services. Data will be ERASED! ⚠️
		servicesCleanIfUp services
		;;

	status) ## <service>... %% 🚦  Display the status of one or more services
		partialServicesStatus services
		;;

	*)
		name="${args_array[0]}"
		cmd="${args_array[1]}"

		if [[ "${name}" == "" ]]; then
			serviceUsage
			exit 1
		fi

		command="${name}:${cmd}"

		if [[ "${#args_array[@]}" -gt 2 ]]; then
			args="${args_array[@]:2}"
		fi

		handleService ${name} ${command}
esac

