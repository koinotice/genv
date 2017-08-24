#!/usr/bin/env bash

declare -A task_aliases

task_aliases=(
	["tf"]="terraform" ["terraform"]="tf"
	["plug"]="plugins" ["plugins"]="plug"
)

export task_aliases

# $1 task name
task_exists() {
	task=${1}

	if [ ${task_aliases[$1]:-} ]; then
		task=${task_aliases[$1]}
	fi

	if [ -d ${TASKS_ROOT}/${task} ]; then
		export TASK_ROOT=${TASKS_ROOT}/${task}
	elif [ -d ${VENDOR_ROOT}/tasks/${task} ]; then
		export TASK_ROOT=${VENDOR_ROOT}/tasks/${task}
	fi
}

tasks() {
	tasks=""

	for f in $(ls ${TASKS_ROOT}); do
		if [[ "$f" == "tasks.sh" || "$f" == "_templates" ]]; then
			continue
		fi

		task=${f}

		if [ ${task_aliases[$f]:-} ]; then
			task=${task_aliases[$f]}
		fi

		tasks+="$task\n"
	done

	if [ -d ${VENDOR_ROOT}/tasks ]; then
		for f in $(ls ${VENDOR_ROOT}/tasks); do
			task=${f}

			# fixme support aliases for vendored tasks
			if [ ${task_aliases[$f]:-} ]; then
				task=${task_aliases[$f]}
			fi

			tasks+="$task\n"
		done
	fi

	echo -e "$tasks" | sort
}

task_help() {
	print_usage
	echo ""
	print_help ${TASK_ROOT}/handler.sh
	echo ""
}

# bootstrap tasks
for f in $(ls ${TASKS_ROOT}); do
	if [[ "$f" == "tasks.sh" || "$f" == "_templates" ]]; then
		continue
	fi

	if [ -f ${TASKS_ROOT}/${f}/bootstrap.sh ]; then
		source ${TASKS_ROOT}/${f}/bootstrap.sh;
	fi
done

if [ -d ${VENDOR_ROOT}/tasks ]; then
	for f in $(ls ${VENDOR_ROOT}/tasks); do
		if [ -f ${VENDOR_ROOT}/tasks/${f}/bootstrap.sh ]; then
			source ${VENDOR_ROOT}/tasks/${f}/bootstrap.sh;
		fi
	done
fi