#!/usr/bin/env bash

harpoon_load() {
	source ${BATS_TEST_DIRNAME}/../$1
}

set_harpoon_roots() {
	export HARPOON_ROOT=${BATS_TEST_DIRNAME}/../
	export TASKS_ROOT=${HARPOON_ROOT}tasks
	export SERVICES_ROOT=${HARPOON_ROOT}services
	echo "HARPOON_ROOT: $HARPOON_ROOT"
	echo "TASKS_ROOT: $TASKS_ROOT"
	echo "SERVICES_ROOT: $SERVICES_ROOT"
}

skip_when_no_docker() {
	if [ ! ${DOCKER_HOST:-} ]; then
		skip
	fi
}