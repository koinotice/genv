#!/usr/bin/env bash

print_help() {
	prefix=""

	if [ ${2:-} ]; then
		prefix="$2:"
	fi

	help=$(grep -E '^\s[a-zA-Z0-9:|_-]+\)\s##\s.*$' ${1} | sort | awk -v prefix="$prefix" 'BEGIN {FS = "\\).*?## |%%"}; {gsub(/\t/,"  "prefix,$1); c=$1" "$2; printf "\033[36m%-45s\033[0m %s\n", c, $3}') || true
	echo -e "$help"
}

tasks_help() {
	if [ -v ROOT_TASKS_FILE ]; then
		printf "\n${PROJECT_TITLE} Tasks:\n"
		print_help ${ROOT_TASKS_FILE} ${PROJECT_TASK_PREFIX}
		if [ -v ADDITIONAL_TASK_FILES ]; then
			IFS=',' read -ra ATFS <<< "$ADDITIONAL_TASK_FILES"
			for i in "${ATFS[@]}"; do
				print_help ${i} ${PROJECT_TASK_PREFIX}
			done
		fi
		echo ""
	fi
}

all_help() {
	print_usage
	echo ""

	print_help "${HARPOON_ROOT}/harpoon"

	printf "  $COLOR_CYAN%-45s$COLOR_NC %s\n" "<service-name>:help" "❓  Get help for a particular service"
	printf "  $COLOR_CYAN%-45s$COLOR_NC %s\n" "<service-name>:<command> [<arg...>]" "Alternative syntax for running a service command"

	tasks_help

	printf "\nTasks:\n"

	for m in $(ls ${TASKS_ROOT}); do
		if [[ "$m" == "tasks.sh" || "$m" == "_templates" ]]; then
			continue
		fi

		printf "  $(tr '[:lower:]' '[:upper:]' <<< ${m}):\n"
		print_help ${TASKS_ROOT}/${m}/handler.sh
		echo ""
	done

	if [ -d ${VENDOR_ROOT}/tasks ]; then
		printf "\nTask Plugins:\n"
		for v in $(ls ${VENDOR_ROOT}/tasks); do
			printf "  $(tr '[:lower:]' '[:upper:]' <<< ${v}):\n"
			print_help ${VENDOR_ROOT}/tasks/${v}/handler.sh
			echo ""
		done
	fi

	printf "\nHarpoon help may be somewhat long...be sure to scroll up to make sure you see everything! 😉\n"
	exit 1
}

help() {
	if [[ "$args" == "" ]]; then all_help; fi

	# try tasks
	task_exists ${args}

	if [ -v TASK_ROOT ]; then
		task_help
	else
		# try services
		service_exists ${args}

		if [ -v SERVICE_ROOT ]; then
			service_help ${args};
		elif [ -v ROOT_TASKS_FILE ]; then
			# try custom task handler in working directory
			tasks_help
		fi
	fi
}