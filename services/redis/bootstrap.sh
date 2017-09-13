#!/usr/bin/env bash

#% 🔺 REDIS_VERSION %% Redis Docker image version %% alpine
if [ ! -v REDIS_VERSION ]; then
	export REDIS_VERSION=alpine
fi

#% 🔺 REDIS_PORT %% Redis TCP port %% 6379
if [ ! -v REDIS_PORT ]; then
	export REDIS_PORT=6379
fi