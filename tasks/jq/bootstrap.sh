#!/usr/bin/env bash

if [ ! ${JQ_IMAGE_VERSION:-} ]; then
	export JQ_IMAGE_VERSION=latest
fi

if [ ! ${JQ_IMAGE:-} ]; then
	export JQ_IMAGE=stedolan/jq:${JQ_IMAGE_VERSION}
fi

if [ ! ${JQ_CMD:-} ]; then
	export JQ_CMD=""
fi

jq_cli() {
	print_debug "jq args: $@"
	docker_run -i ${JQ_IMAGE} ${JQ_CMD} $@
}