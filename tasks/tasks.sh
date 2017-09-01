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

	if [ -d ${HARPOON_TASKS_ROOT}/${task} ]; then
		export TASK_ROOT=${HARPOON_TASKS_ROOT}/${task}
	elif [ -d ${HARPOON_VENDOR_ROOT}/tasks/${task} ]; then
		export TASK_ROOT=${HARPOON_VENDOR_ROOT}/tasks/${task}
	fi
}

listTasks() {
	local tasks=""

	for f in $(ls ${HARPOON_TASKS_ROOT}); do
		if [[ "$f" == "tasks.sh" || "$f" == "_templates" ]]; then
			continue
		fi

		local task=${f}

		if [ ${task_aliases[$f]:-} ]; then
			local task=${task_aliases[$f]}
		fi

		local tasks+="$task\n"
	done

	if [ -d ${HARPOON_VENDOR_ROOT}/tasks ]; then
		for f in $(ls ${HARPOON_VENDOR_ROOT}/tasks); do
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
for f in $(ls ${HARPOON_TASKS_ROOT}); do
	if [[ "$f" == "tasks.sh" || "$f" == "_templates" ]]; then
		continue
	fi

	if [ -f ${HARPOON_TASKS_ROOT}/${f}/bootstrap.sh ]; then
		source ${HARPOON_TASKS_ROOT}/${f}/bootstrap.sh;
	fi
done

if [ -d ${HARPOON_VENDOR_ROOT}/tasks ]; then
	for f in $(ls ${HARPOON_VENDOR_ROOT}/tasks); do
		if [ -f ${HARPOON_VENDOR_ROOT}/tasks/${f}/bootstrap.sh ]; then
			source ${HARPOON_VENDOR_ROOT}/tasks/${f}/bootstrap.sh;
		fi
	done
fi