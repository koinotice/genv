#!/usr/bin/env bash

harpoonLoad() {
	source ${BATS_TEST_DIRNAME}/../$1
}

setHarpoonRoots() {
	export HARPOON_ROOT=${BATS_TEST_DIRNAME}/../
	export TASKS_ROOT=${HARPOON_ROOT}tasks
	export SERVICES_ROOT=${HARPOON_ROOT}services
	echo "HARPOON_ROOT: $HARPOON_ROOT"
	echo "TASKS_ROOT: $TASKS_ROOT"
	echo "SERVICES_ROOT: $SERVICES_ROOT"
}