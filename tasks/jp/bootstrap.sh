#!/usr/bin/env bash

#% 🔺 JP_IMAGE_VERSION %% jp CLI Docker image version %% latest
if [ ! ${JP_IMAGE_VERSION:-} ]; then
	export JP_IMAGE_VERSION=latest
fi

#todo
#% 🔺 JP_IMAGE %% jp CLI Docker image
if [ ! ${JP_IMAGE:-} ]; then
	export JP_IMAGE=fixme:${JP_IMAGE_VERSION}
fi

#% 🔺 JP_CMD %% Override command for jp CLI Docker container %%
if [ ! ${JP_CMD:-} ]; then
	export JP_CMD=""
fi

jp_cli() {
	printDebug "jp args: $@"
	dockerRun -i ${JP_IMAGE} ${JP_CMD} $@
}