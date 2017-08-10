#!/usr/bin/env bash

print_help() {
	prefix=""

	if [ ${2:-} ]; then
		prefix="$2:"
	fi

	help=$(grep -E '^\s[a-zA-Z:|_-]+\)\s##\s.*$' ${1} | sort | awk -v prefix="$prefix" 'BEGIN {FS = "\\).*?## |%%"}; {gsub(/\t/,"\t"prefix,$1); c=$1" "$2; printf "\033[36m%-45s\033[0m %s\n", c, $3}') || true
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
	echo "Usage: harpoon command [<arg>...]"
	echo ""
	print_help "${HARPOON_ROOT}/harpoon"
	printf "\t$LTBLU%-45s$NC %s\n" "(service):help" "❓  Get help for a particular service"

	tasks_help

	printf "\nModules:\n"

	for m in $(ls ${MODULES_ROOT}); do
		if [[ "$m" == "modules.sh" ]]; then
			continue
		fi

		# DEPRECATED
		if [[ "$m" == "custom" ]]; then
			CUSTOM_EXISTS=true
			continue
		fi

		printf "\t$(tr '[:lower:]' '[:upper:]' <<< ${m}):\n"
		print_help ${MODULES_ROOT}/${m}/handler.sh
		echo ""
	done

	if [ -d ${VENDOR_ROOT}/modules ]; then
		printf "\nPlugin Modules:\n"
		for v in $(ls ${VENDOR_ROOT}/modules); do
			printf "\t$(tr '[:lower:]' '[:upper:]' <<< ${v}):\n"
			print_help ${VENDOR_ROOT}/modules/${v}/handler.sh
			echo ""
		done
	fi

	# DEPRECATED
	if [ -v CUSTOM_EXISTS ]; then
		printf "\nCustom Modules:\n"
		for c in $(ls ${MODULES_ROOT}/custom); do
			printf "\t$(tr '[:lower:]' '[:upper:]' <<< ${c}):\n"
			print_help ${MODULES_ROOT}/custom/${c}/handler.sh
			echo ""
		done
	fi

	printf "\nHarpoon help may be somewhat long...be sure to scroll up to make sure you see everything! 😉\n"
	exit 1
}
