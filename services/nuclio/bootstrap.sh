#!/usr/bin/env bash

#% 🔺 TRAEFIK_DOCKER_TAGS %% Redis Docker image version %% alpine
if [ ! -v TRAEFIK_DOCKER_TAGS ]; then
	export TRAEFIK_DOCKER_TAGS=2123
fi

