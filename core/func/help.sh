#!/usr/bin/env bash

printHelp() {
	local prefix=""

	if [ ${2:-} ]; then
		local prefix="$2:"
	fi

	local help=$(grep -E '^\s[a-zA-Z0-9:|_-]+\)\s##\s.*$' ${1} | sort | awk -v prefix="$prefix" 'BEGIN {FS = "\\).*?## |%%"}; {gsub(/\t/,"  "prefix,$1); c=$1" "$2; printf "\033[36m%-45s\033[0m %s\n", c, $3}') || true
	echo -e "$help"
}

printAllHelp() {
	printUsage
	echo ""
	echo "Commands:"
	printHelp "${HARPOON_ROOT}/harpoon"

	printf "  $COLOR_CYAN%-45s$COLOR_NC %s\n" "<service-name>:help" "❓  Get help for a particular service"
	printf "  $COLOR_CYAN%-45s$COLOR_NC %s\n" "<service-name>:<command> [<arg...>]" "Alternative syntax for running a service command"

	tasksHelp

	printf "\nTasks:\n"

	for m in $(ls ${HARPOON_TASKS_ROOT}); do
		if [[ "$m" == "tasks.sh" || "$m" == "_templates" ]]; then
			continue
		fi

		printf "  $(tr '[:lower:]' '[:upper:]' <<< ${m}):\n"
		printHelp ${HARPOON_TASKS_ROOT}/${m}/handler.sh
		echo ""
	done

	if [ -d ${HARPOON_VENDOR_ROOT}/tasks ]; then
		printf "\nTask Plugins:\n"
		for v in $(ls ${HARPOON_VENDOR_ROOT}/tasks); do
			printf "  $(tr '[:lower:]' '[:upper:]' <<< ${v}):\n"
			printHelp ${HARPOON_VENDOR_ROOT}/tasks/${v}/handler.sh
			echo ""
		done
	fi

	printf "\nHarpoon help may be somewhat long...be sure to scroll up to make sure you see everything! 😉\n"
	exit 1
}

help() {
	if [[ "$args" == "" ]]; then printAllHelp; fi

	# try tasks
	taskExists ${args}

	if [ -v TASK_ROOT ]; then
		taskHelp
	else
		# try services
		svcRoot=$(serviceRoot ${args})

		if [[ "$svcRoot" != "" ]]; then
			serviceHelp ${args};
		elif [ -v ROOT_TASKS_FILE ]; then
			# try custom task handler in working directory
			tasksHelp
		fi
	fi
}