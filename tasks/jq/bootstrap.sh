#!/usr/bin/env bash

#% 🔺 JQ_IMAGE_VERSION %% jq CLI Docker image version %% latest
if [ ! ${JQ_IMAGE_VERSION:-} ]; then
	export JQ_IMAGE_VERSION=latest
fi

#% 🔺 JQ_IMAGE %% jq CLI Docker image %% stedolan/jq:${JQ_IMAGE_VERSION}
if [ ! ${JQ_IMAGE:-} ]; then
	export JQ_IMAGE=stedolan/jq:${JQ_IMAGE_VERSION}
fi

#% 🔺 JQ_CMD %% Override command for jq CLI Docker container %%
if [ ! ${JQ_CMD:-} ]; then
	export JQ_CMD=""
fi

jq_cli() {
	printDebug "jq args: $@"
	dockerRun -i ${JQ_IMAGE} ${JQ_CMD} $@
}