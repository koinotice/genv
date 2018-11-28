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
	printInfo "Inspecting metadata for $PLUGIN..."

	local metadata=$(docker image inspect -f "{{json .ContainerConfig.Labels}}" ${PLUGIN})
	printDebug "METADATA: $metadata"

	export NAME=$(jq_cli -r ".genv_name" <<< ${metadata})
	printDebug "NAME: $NAME"

	export TYPE=$(jq_cli -r ".genv_type" <<< ${metadata})
	printDebug "TYPE: $TYPE"

	export CMD_ARGS=$(jq_cli -r ".genv_args" <<< ${metadata})
	printDebug "CMD_ARGS: $CMD_ARGS"

	export DESCRIPTION=$(jq_cli -r ".genv_description" <<< ${metadata})
	printDebug "DESCRIPTION: $DESCRIPTION"

	IMAGE_DIR=$(jq_cli -r ".genv_dir" <<< ${metadata})

	if [[ ${IMAGE_DIR} == null ]]; then
		IMAGE_DIR=${NAME}
	fi

	export IMAGE_DIR
	printDebug "IMAGE_DIR: $IMAGE_DIR"

	if [[ ${NAME} == null || ${TYPE} == null ]]; then
		printPanic "${PLUGIN} is not a Genv plugin"
	fi
}

pluginRoot() {
	case "$TYPE" in
		module) # deprecated
			printWarn "Plugin type 'module' has been deprecated, please change to 'task'."
			export PLUGIN_ROOT=${GENV_VENDOR_ROOT}/tasks ;;
		task)
			export PLUGIN_ROOT=${GENV_VENDOR_ROOT}/tasks ;;
		service)
			export PLUGIN_ROOT=${GENV_VENDOR_ROOT}/services ;;
		*)
			printPanic "Unknown plugin type '$TYPE'"
	esac
}

extractPlugin() {
	printInfo "Extracting $TYPE '$NAME'..."

	pluginRoot

	if [[ "${ACTION:-}" == "Updated" ]]; then
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

		source ${GENV_LIB_ROOT}/mo/mo

		cat ${GENV_TASKS_ROOT}/_templates/bootstrap.mo | mo > ${PLUGIN_ROOT}/${NAME}/bootstrap.sh

		if [[ ${CMD_ARGS} == null ]]; then
			export CMD_ARGS=""
		fi

		if [[ ${DESCRIPTION} == null ]]; then
			export DESCRIPTION=""
		else
			echo "${DESCRIPTION}" > ${PLUGIN_ROOT}/${NAME}/info.txt
		fi

		cat ${GENV_TASKS_ROOT}/_templates/handler.mo | mo > ${PLUGIN_ROOT}/${NAME}/handler.sh

		set -u
	fi

	docker rm ${containerID} > /dev/null
}

pluginInstalled() {
	PLUGIN_INSTALLED=$(grep ${REPO} ${PLUGINS_FILE}) || PLUGIN_INSTALLED=""
	export PLUGIN_INSTALLED
	printDebug "PLUGIN_INSTALLED: $PLUGIN_INSTALLED"
}

removePluginRecord() {
	grep -v ${PLUGIN_INSTALLED} ${PLUGINS_FILE} | tee ${PLUGINS_FILE} > /dev/null
}

install() {
	parsePlugin ${1}

	pluginInstalled

	if [[ "$PLUGIN_INSTALLED" != "" && ! -v PLUGIN_REINSTALL ]]; then
		printPanic "${REPO} is already installed. Perhaps you'd like to run 'plug:up' instead?"
	fi

	docker pull ${PLUGIN}

	inspectMetadata

	extractPlugin

	if [ ! -v PLUGIN_REINSTALL ]; then
		echo "$PLUGIN" >> ${PLUGINS_FILE}
	fi

	printSuccess "Installed $TYPE '$NAME'"
}

# $1 filename
installFromFile() {
	plugins=$(cat ${1})

	for p in ${plugins}; do
		[[ ${p} =~ ^# ]] && continue
		install "${p}"
	done
}

update() {
	parsePlugin ${1}

	pluginInstalled

	export ACTION=Updated

	if [[ "$PLUGIN_INSTALLED" == "" ]]; then
		printWarn "${REPO} is not installed..."
		export ACTION=Installing
	fi

	docker pull ${PLUGIN}

	inspectMetadata

	extractPlugin

	if [[ "$PLUGIN" != "$PLUGIN_INSTALLED" ]]; then
		removePluginRecord
		echo "$PLUGIN" >> ${PLUGINS_FILE}
		printInfo "Replaced $PLUGIN_INSTALLED with $PLUGIN"
	fi

	printSuccess "$ACTION $TYPE '$NAME'"
}

case "${command}" in
	plug:in) ## <plugin> %% Install a Genv plugin
		install "${args}" ;;

	plug:reinstall) ## %% Reinstall all Genv plugins
		PLUGIN_REINSTALL=true

		rm -fr ${GENV_VENDOR_ROOT}

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

	plug:up) ## <plugin> %% Update a Genv plugin
		update "${args}" ;;

	plug:up:all) ## %% Update all Genv plugins
		plugins=$(cat ${PLUGINS_FILE})

		for p in ${plugins}; do
        	update "${p}"
      	done
		;;

	plug:rm) ## <plugin> %% Remove a Genv plugin
		parsePlugin "${args}"

		pluginInstalled

		if [[ "$PLUGIN_INSTALLED" == "" ]]; then
			printPanic "${REPO} is not installed..."
		fi

		inspectMetadata

		pluginRoot

		rm -fr ${PLUGIN_ROOT}
		removePluginRecord

		printSuccess "Removed $TYPE '$NAME'"
		;;

	plug:rm:all) ## %% Remove all Genv plugins
		rm -fr ${GENV_VENDOR_ROOT}

		plugins=$(cat ${PLUGINS_FILE})

		for p in ${plugins}; do
			docker rmi "${p}" || true
      	done

		rm -f ${PLUGINS_FILE}
		;;

	plug:ls) ## %% List Genv plugins
		printInfo "Genv plugins:"
		cat ${PLUGINS_FILE}
		echo ""
		;;

	*)
		taskHelp
esac