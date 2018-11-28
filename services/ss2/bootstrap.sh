#!/usr/bin/env bash

#% 🔺 REDIS_VERSION %% Redis Docker image version %% alpine
if [ ! -v SS2_VERSION ]; then
	export SS2_VERSION=latest
fi

#% 🔺 REDIS_PORT %% Redis TCP port %% 6379
if [ ! -v SS2_PORT ]; then
	export SS2_PORT=4430
fi

#% 🔺 REDIS_PORT %% Redis TCP port %% 6379
if [ ! -v SS2_PASSWORD ]; then
	export SS2_PASSWORD=root
fi