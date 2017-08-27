#!/usr/bin/env bash

touch ${PLUGINS_FILE}

parsePlugin() {
	PLUGIN=${1}

	printInfo "Processing plugin $PLUGIN..."

	export REPO=${PLUGIN%:*}

	TAG=${PLUGIN#*:}

	if [[ ${TAG} == ${REPO} ]]; then
		TAG=latest
		PLUGIN=${REPO}:${TAG}
	fi

	export TAG
	export PLUGIN

	printDebug "PLUGIN: $PLUGIN"
	printDebug "REPO: $REPO"
	printDebug "TAG: $TAG"
}

inspectMetadata() {
	local metadata=$(docker image inspect -f "{{json .ContainerConfig.Labels}}" ${PLUGIN})
	printDebug "METADATA: $metadata"

	export NAME=$(jq_cli -r ".harpoon_name" <<< ${metadata})
	export TYPE=$(jq_cli -r ".harpoon_type" <<< ${metadata})
	export CMD_ARGS=$(jq_cli -r ".harpoon_args" <<< ${metadata})
	export DESCRIPTION=$(jq_cli -r ".harpoon_description" <<< ${metadata})
	IMAGE_DIR=$(jq_cli -r ".harpoon_dir" <<< ${metadata})

	if [[ ${IMAGE_DIR} == null ]]; then
		IMAGE_DIR=${NAME}
	fi

	export IMAGE_DIR
	printDebug "IMAGE_DIR: $IMAGE_DIR"

	if [[ ${NAME} == null || ${TYPE} == null ]]; then
		printPanic "${PLUGIN} is not a Harpoon plugin"
	fi
}

pluginRoot() {
	case "$TYPE" in
		module) # deprecated
			printWarn "Plugin type 'module' has been deprecated, please change to 'task'."
			export PLUGIN_ROOT=${HARPOON_VENDOR_ROOT}/tasks ;;
		task)
			export PLUGIN_ROOT=${HARPOON_VENDOR_ROOT}/tasks ;;
		service)
			export PLUGIN_ROOT=${HARPOON_VENDOR_ROOT}/services ;;
		*)
			printPanic "Unknown plugin type '$TYPE'"
	esac
}

extractPlugin() {
	pluginRoot

	if [[ "${ACTION:-}" == "Updating" ]]; then
		rm -fr ${PLUGIN_ROOT}/${NAME}
	fi

	local containerID=$(docker create ${PLUGIN} true)

	mkdir -p ${PLUGIN_ROOT}/${NAME}
	docker cp ${containerID}:/${IMAGE_DIR} /tmp/ > /dev/null || true

	if [ -d /tmp/${IMAGE_DIR} ]; then
		mv /tmp/${IMAGE_DIR}/* ${PLUGIN_ROOT}/${NAME}/
		rm -fr /tmp/${IMAGE_DIR}
	fi

	if [[ "$TYPE" == "task" && ! -f ${PLUGIN_ROOT}/${NAME}/handler.sh ]]; then
		printInfo "Generating '${NAME}' wrapper..."

		set +u

		source ${HARPOON_LIB_ROOT}/mo/mo

		cat ${HARPOON_TASKS_ROOT}/_templates/bootstrap.mo | mo > ${PLUGIN_ROOT}/${NAME}/bootstrap.sh

		if [[ ${CMD_ARGS} == null ]]; then
			export CMD_ARGS=""
		fi

		if [[ ${DESCRIPTION} == null ]]; then
			export DESCRIPTION=""
		fi

		cat ${HARPOON_TASKS_ROOT}/_templates/handler.mo | mo > ${PLUGIN_ROOT}/${NAME}/handler.sh

		set -u
	fi

	docker rm ${containerID} > /dev/null
}

pluginInstalled() {
	PLUGIN_INSTALLED=$(grep ${REPO} ${PLUGINS_FILE}) || PLUGIN_INSTALLED=""
	export PLUGIN_INSTALLED
}

tagInstalled() {
	TAG_INSTALLED=true
	grep ${PLUGIN} ${PLUGINS_FILE} > /dev/null || TAG_INSTALLED=false
	export TAG_INSTALLED
}

removePluginRecord() {
	cat ${PLUGINS_FILE} | sed "s#${PLUGIN_INSTALLED}##" > ${PLUGINS_FILE}
}

install() {
	parsePlugin ${1}

	pluginInstalled

	if [[ "$PLUGIN_INSTALLED" != "" && ! -v PLUGIN_REINSTALL ]]; then
		printPanic "${REPO} is already installed. Perhaps you'd like to run 'plug:up' instead?"
	fi

	docker pull ${PLUGIN}

	inspectMetadata

	printInfo "Installing $TYPE '$NAME'..."

	extractPlugin

	if [ ! -v PLUGIN_REINSTALL ]; then
		echo "$PLUGIN" >> ${PLUGINS_FILE}
	fi
}

# $1 filename
installFromFile() {
	for p in $(cat ${1}); do
		[[ ${p} =~ ^# ]] && continue
		install "${p}"
	done
}

update() {
	parsePlugin ${1}

	pluginInstalled

	export ACTION=Updating

	if [[ "$PLUGIN_INSTALLED" == "" ]]; then
		printWarn "${REPO} is not installed..."
		export ACTION=Installing
	fi

	docker pull ${PLUGIN}

	inspectMetadata

	printInfo "$ACTION $TYPE '$NAME'..."

	extractPlugin

	if [[ "$PLUGIN_INSTALLED" != "" ]]; then
		removePluginRecord
		printSuccess "Replaced $PLUGIN_INSTALLED with $PLUGIN"
	fi

	echo "$PLUGIN" >> ${PLUGINS_FILE}
}

case "${command}" in
	plug:in) ## <plugin> %% Install a Harpoon plugin
		install "${args}" ;;

	plug:reinstall) ## %% Reinstall all Harpoon plugins
		PLUGIN_REINSTALL=true

		rm -fr ${HARPOON_VENDOR_ROOT}

		installFromFile ${PLUGINS_FILE}
      	;;

	plug:in:file) ## [<filename>] %% Install plugins listed in a text file [default: ./plugins.txt]
		if [ -f "${args}" ]; then
			filename="${args}"
		elif [ -f "./plugins.txt" ]; then
			filename="./plugins.txt"
		else
			printPanic "Please specify a filename, or create a plugins.txt in the current directory."
		fi

		installFromFile ${filename}
		;;

	plug:up) ## <plugin> %% Update a Harpoon plugin
		update "${args}" ;;

	plug:up:all) ## %% Update all Harpoon plugins
		for p in $(cat ${PLUGINS_FILE}); do
        	update "${p}"
      	done
		;;

	plug:rm) ## <plugin> %% Remove a Harpoon plugin
		parsePlugin "${args}"

		pluginInstalled

		if [[ "$PLUGIN_INSTALLED" == "" ]]; then
			printPanic "${REPO} is not installed..."
		fi

		inspectMetadata

		pluginRoot

		printInfo "Removing $TYPE '$NAME'..."

		rm -fr ${PLUGIN_ROOT}
		removePluginRecord
		;;

	plug:rm:all) ## %% Remove all Harpoon plugins
		rm -fr ${HARPOON_VENDOR_ROOT}

		for p in $(cat ${PLUGINS_FILE}); do
			docker rmi "${p}" || true
      	done

		rm -f ${PLUGINS_FILE}
		;;

	plug:ls) ## %% List Harpoon plugins
		printInfo "Harpoon plugins:"
		cat ${PLUGINS_FILE}
		echo ""
		;;

	*)
		taskHelp
esac