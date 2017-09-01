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
	projectTasksHelp

	printf "\nTasks:\n"
	printf "  $COLOR_CYAN%-45s$COLOR_NC %s\n" "<task>:<command> [<arg...>]"
	printf "  $COLOR_CYAN%-45s$COLOR_NC%s\n\n" "<task>:help"
	for t in $(listTasks); do
		taskExists ${t}
		infoFile="${TASK_ROOT}/info.txt"

		if [ -f ${infoFile} ]; then
			info=$(cat ${infoFile} | head -n 1)
		else
			info=""
		fi

		printf "  $COLOR_CYAN%-20s$COLOR_NC %s\n" "${t}" "${info}"
	done

	printf "\nServices:\n"
	printf "  $COLOR_CYAN%-45s$COLOR_NC %s\n" "<service>:<command> [<arg...>]"
	printf "  $COLOR_CYAN%-45s$COLOR_NC%s\n\n" "<service>:help"
	for s in $(listServices); do
		svcRoot=$(serviceRoot ${s})

		infoFile="${svcRoot}/info.txt"

		if [ -f ${infoFile} ]; then
			info=$(cat ${infoFile} | head -n 1)
		else
			info=""
		fi

		printf "  $COLOR_CYAN%-20s$COLOR_NC %s\n" "${s}" "${info}"
	done
	echo ""
	printf "\nℹ️  Run '${COLOR_CYAN}harpoon help [<task> | <service>]${COLOR_NC}' for more information\n"
	exit 1
}

projectTasksHelp() {
	if [ -v ROOT_TASKS_FILE ]; then
		printf "\n${PROJECT_TITLE} Tasks:\n"
		printHelp ${ROOT_TASKS_FILE} ${PROJECT_TASK_PREFIX}
		if [ -v ADDITIONAL_TASK_FILES ]; then
			IFS=',' read -ra ATFS <<< "$ADDITIONAL_TASK_FILES"
			for i in "${ATFS[@]}"; do
				printHelp ${i} ${PROJECT_TASK_PREFIX}
			done
		fi
		echo ""
	fi
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
			projectTasksHelp
		fi
	fi
}