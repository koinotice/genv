#!/usr/bin/env bash

if [ ! -v HARPOON_{{NAME}}_IMAGE_VERSION ]; then
	export HARPOON_{{NAME}}_IMAGE_VERSION=latest
fi

if [ ! -v HARPOON_{{NAME}}_IMAGE ]; then
	export HARPOON_{{NAME}}_IMAGE={{REPO}}:${HARPOON_{{NAME}}_IMAGE_VERSION}
fi

if [ ! -v HARPOON_{{NAME}}_CMD ]; then
	export HARPOON_{{NAME}}_CMD=""
fi

harpoon_{{NAME}}_cli() {
	print_debug "{{NAME}} args: $@"
	docker_run -i ${HARPOON_{{NAME}}_IMAGE} ${HARPOON_{{NAME}}_CMD} $@
}