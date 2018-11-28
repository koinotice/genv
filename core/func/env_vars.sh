#!/usr/bin/env bash

printEnv() {
	local envs=$(grep -r -E '^#%\s.*$' ${1} | sort | awk 'BEGIN {FS = ": |#% | %% "}; {printf "    \033[1;35m%-35s\033[0m\033[36m%s\033[0m [default: %s]\n", $2, $3, $4}') || true
	if [[ "${envs}" != "" ]]; then
		echo -e "$envs"
	fi
}

printAllEnv() {
	echo "  Core:"
	printEnv "${GENV_ROOT}/genv"
	printEnv "${GENV_ROOT}/core"
	projectTasksEnv
	echo ""
	exit 0
}

projectTasksEnv() {
	if [ -v ROOT_TASKS_FILE ]; then
		printf "\n${PROJECT_TITLE} Tasks:\n"
		printEnv ${ROOT_TASKS_FILE}
		if [ -v ADDITIONAL_TASK_FILES ]; then
			IFS=',' read -ra ATFS <<< "$ADDITIONAL_TASK_FILES"
			for i in "${ATFS[@]}"; do
				printEnv ${i}
			done
		fi
	fi
}

printModuleInfo() {
	if [ -f ${1} ]; then
		info=$(cat ${1} | head -n 1)
	else
		info=""
	fi

	printf "  %-35s%s\n" "${2}:" "${info}"
}

envdoc() {
	echo -e "\nGenv Environment Variables (🔺  = overridable, 🔹  = static):"
	if [[ "$args" == "" ]]; then printAllEnv; fi

	# try tasks
	taskExists ${args}

	if [ -v TASK_ROOT ]; then
		printModuleInfo "${TASK_ROOT}/info.txt" "${args}"
		printEnv ${TASK_ROOT}
	else
		# try services
		svcRoot=$(serviceRoot ${args})

		if [[ "$svcRoot" != "" ]]; then
			printModuleInfo "${svcRoot}/info.txt" "${args}"
			printEnv ${svcRoot};
		elif [ -v ROOT_TASKS_FILE ]; then
			# try custom task handler in working directory
			projectTasksEnv
		fi
	fi
	echo ""
}