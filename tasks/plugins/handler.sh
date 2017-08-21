#!/usr/bin/env bash

touch ${PLUGINS_FILE}

parse_plugin() {
	PLUGIN=${1}

	print_info "Processing plugin $PLUGIN..."

	export REPO=${PLUGIN%:*}

	TAG=${PLUGIN#*:}

	if [[ ${TAG} == ${REPO} ]]; then
		TAG=latest
		PLUGIN=${REPO}:${TAG}
	fi

	export TAG
	export PLUGIN

	print_debug "PLUGIN: $PLUGIN"
	print_debug "REPO: $REPO"
	print_debug "TAG: $TAG"
}

inspect_metadata() {
	METADATA=$(docker image inspect -f "{{json .ContainerConfig.Labels}}" ${PLUGIN})
	print_debug "METADATA: $METADATA"

	export NAME=$(jq_cli -r ".harpoon_name" <<< ${METADATA})
	export TYPE=$(jq_cli -r ".harpoon_type" <<< ${METADATA})
	export CMD_ARGS=$(jq_cli -r ".harpoon_args" <<< ${METADATA})
	export DESCRIPTION=$(jq_cli -r ".harpoon_description" <<< ${METADATA})
	IMAGE_DIR=$(jq_cli -r ".harpoon_dir" <<< ${METADATA})

	if [[ ${IMAGE_DIR} == null ]]; then
		IMAGE_DIR=${NAME}
	fi

	export IMAGE_DIR
	print_debug "IMAGE_DIR: $IMAGE_DIR"

	if [[ ${NAME} == null || ${TYPE} == null ]]; then
		print_panic "${PLUGIN} is not a Harpoon plugin"
	fi
}

plugin_root() {
	case "$TYPE" in
		module) # deprecated
			print_warn "Plugin type 'module' has been deprecated, please change to 'task'."
			PLUGIN_ROOT=${VENDOR_ROOT}/tasks ;;
		task)
			PLUGIN_ROOT=${VENDOR_ROOT}/tasks ;;
		service)
			PLUGIN_ROOT=${VENDOR_ROOT}/services ;;
		*)
			print_panic "Unknown plugin type '$TYPE'"
	esac
}

extract_plugin() {
	plugin_root

	if [[ "${ACTION:-}" == "Updating" ]]; then
		rm -fr ${PLUGIN_ROOT}/${NAME}
	fi

	CID=$(docker create ${PLUGIN} true)

	mkdir -p ${PLUGIN_ROOT}/${NAME}
	docker cp ${CID}:/${IMAGE_DIR} /tmp/ > /dev/null || true

	if [ -d /tmp/${IMAGE_DIR} ]; then
		mv /tmp/${IMAGE_DIR}/* ${PLUGIN_ROOT}/${NAME}/
		rm -fr /tmp/${IMAGE_DIR}
	fi

	if [[ "$TYPE" == "task" && ! -f ${PLUGIN_ROOT}/${NAME}/handler.sh ]]; then
		print_info "Generating '${NAME}' wrapper..."

		set +u

		source ${LIB_ROOT}/mo/mo

		cat ${TASKS_ROOT}/_templates/bootstrap.mo | mo > ${PLUGIN_ROOT}/${NAME}/bootstrap.sh

		if [[ ${CMD_ARGS} == null ]]; then
			export CMD_ARGS=""
		fi

		if [[ ${DESCRIPTION} == null ]]; then
			export DESCRIPTION=""
		fi

		cat ${TASKS_ROOT}/_templates/handler.mo | mo > ${PLUGIN_ROOT}/${NAME}/handler.sh

		set -u
	fi

	docker rm ${CID} > /dev/null
}

plugin_installed() {
	PLUGIN_INSTALLED=$(grep ${REPO} ${PLUGINS_FILE}) || PLUGIN_INSTALLED=""
	export PLUGIN_INSTALLED
}

tag_installed() {
	TAG_INSTALLED=true
	grep ${PLUGIN} ${PLUGINS_FILE} > /dev/null || TAG_INSTALLED=false
	export TAG_INSTALLED
}

remove_plugin_record() {
	cat ${PLUGINS_FILE} | sed "s#${PLUGIN_INSTALLED}##" > ${PLUGINS_FILE}
}

install() {
	parse_plugin ${1}

	plugin_installed

	if [[ "$PLUGIN_INSTALLED" != "" && ! -v PLUGIN_REINSTALL ]]; then
		print_panic "${REPO} is already installed. Perhaps you'd like to run 'plug:up' instead?"
	fi

	docker pull ${PLUGIN}

	inspect_metadata

	print_info "Installing $TYPE '$NAME'..."

	extract_plugin

	if [ ! -v PLUGIN_REINSTALL ]; then
		echo "$PLUGIN" >> ${PLUGINS_FILE}
	fi
}

# $1 filename
install_from_file() {
	for p in $(cat ${1}); do
		[[ ${p} =~ ^# ]] && continue
		install "${p}"
	done
}

update() {
	parse_plugin ${1}

	plugin_installed

	export ACTION=Updating

	if [[ "$PLUGIN_INSTALLED" == "" ]]; then
		print_warn "${REPO} is not installed..."
		export ACTION=Installing
	fi

	docker pull ${PLUGIN}

	inspect_metadata

	print_info "$ACTION $TYPE '$NAME'..."

	extract_plugin

	if [[ "$PLUGIN_INSTALLED" != "" ]]; then
		remove_plugin_record
		print_success "Replaced $PLUGIN_INSTALLED with $PLUGIN"
	fi

	echo "$PLUGIN" >> ${PLUGINS_FILE}
}

case "${command:-}" in

	plug:in) ## <plugin> %% Install a Harpoon plugin
		install "${args}" ;;

	plug:reinstall) ## %% Reinstall all Harpoon plugins
		PLUGIN_REINSTALL=true

		rm -fr ${VENDOR_ROOT}

		install_from_file ${PLUGINS_FILE}
      	;;

	plug:in:file) ## [<filename>] %% Install plugins listed in a text file [default: ./plugins.txt]
		if [ -f "${args}" ]; then
			filename="${args}"
		elif [ -f "./plugins.txt" ]; then
			filename="./plugins.txt"
		else
			print_panic "Please specify a filename, or create a plugins.txt in the current directory."
		fi

		install_from_file ${filename}
		;;

	plug:up) ## <plugin> %% Update a Harpoon plugin
		update "${args}" ;;

	plug:up:all) ## %% Update all Harpoon plugins
		for p in $(cat ${PLUGINS_FILE}); do
        	update "${p}"
      	done
		;;

	plug:rm) ## <plugin> %% Remove a Harpoon plugin
		parse_plugin "${args}"

		plugin_installed

		if [[ "$PLUGIN_INSTALLED" == "" ]]; then
			print_panic "${REPO} is not installed..."
		fi

		inspect_metadata

		plugin_root

		print_info "Removing $TYPE '$NAME'..."

		rm -fr ${PLUGIN_ROOT}
		remove_plugin_record
		;;

	plug:rm:all) ## %% Remove all Harpoon plugins
		rm -fr ${VENDOR_ROOT}

		for p in $(cat ${PLUGINS_FILE}); do
			docker rmi "${p}" || true
      	done

		rm -f ${PLUGINS_FILE}
		;;

	plug:ls) ## %% List Harpoon plugins
		print_info "Harpoon plugins:"
		cat ${PLUGINS_FILE}
		echo ""
		;;

	*)
		task_help
esac