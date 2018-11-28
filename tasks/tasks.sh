#!/usr/bin/env bash

declare -A task_aliases

task_aliases=(
	["tf"]="terraform" ["terraform"]="tf"
	["plug"]="plugins" ["plugins"]="plug"
)

export task_aliases

# $1 task name
taskExists() {
	local task=$1

	if [ ${task_aliases[$1]:-} ]; then
		local task=${task_aliases[$1]}
	fi

	if [ -d ${GENV_TASKS_ROOT}/${task} ]; then
		export TASK_ROOT=${GENV_TASKS_ROOT}/${task}
	elif [ -d ${GENV_VENDOR_ROOT}/tasks/${task} ]; then
		export TASK_ROOT=${GENV_VENDOR_ROOT}/tasks/${task}
	fi
}

listTasks() {
	local tasks=""

	local tsks=$(ls ${GENV_TASKS_ROOT})
	for f in ${tsks}; do
		if [[ "$f" == "tasks.sh" || "$f" == "_templates" ]]; then
			continue
		fi

		local task=${f}

		if [ ${task_aliases[$f]:-} ]; then
			local task=${task_aliases[$f]}
		fi

		local tasks+="$task\n"
	done

	if [ -d ${GENV_VENDOR_ROOT}/tasks ]; then
		local tsks=$(ls ${GENV_VENDOR_ROOT}/tasks)
		for f in ${tsks}; do
			local task=${f}

			# fixme support aliases for vendored tasks
			if [ ${task_aliases[$f]:-} ]; then
				local task=${task_aliases[$f]}
			fi

			local tasks+="$task\n"
		done
	fi

	echo -e "$tasks" | sort
}

taskHelp() {
	printUsage
	echo ""
	printHelp ${TASK_ROOT}/handler.sh
	echo ""
}

# DEPRECATED
task_help() {
	printWarn "task_help() is deprecated. Please use taskHelp()."
	taskHelp
}

# bootstrap tasks
TASKS=$(ls ${GENV_TASKS_ROOT})
for f in ${TASKS}; do
	if [[ "$f" == "tasks.sh" || "$f" == "_templates" ]]; then
		continue
	fi

	if [ -f ${GENV_TASKS_ROOT}/${f}/bootstrap.sh ]; then
		source ${GENV_TASKS_ROOT}/${f}/bootstrap.sh;
	fi
done

if [ -d ${GENV_VENDOR_ROOT}/tasks ]; then
	TASKS=$(ls ${GENV_VENDOR_ROOT}/tasks)
	for f in ${TASKS}; do
		if [ -f ${GENV_VENDOR_ROOT}/tasks/${f}/bootstrap.sh ]; then
			source ${GENV_VENDOR_ROOT}/tasks/${f}/bootstrap.sh;
		fi
	done
fi