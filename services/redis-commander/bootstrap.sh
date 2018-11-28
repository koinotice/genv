#!/usr/bin/env bash

if [ ! ${TRAEFIK_ACME:-} ]; then
	export REDIS_COMMANDER_HOSTS=redis-commander.genv
fi

if [ ${CUSTOM_DOMAINS:-} ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export REDIS_COMMANDER_HOSTS+=",redis-commander.${i}"
	done
fi

#% 🔺 REDIS_COMMANDER_VERSION %% Redis Commander Docker image version %% latest
if [ ! -v REDIS_COMMANDER_VERSION ]; then
	export REDIS_COMMANDER_VERSION=latest
fi

if [ ! ${REDIS_HOSTS:-} ]; then
	export REDIS_HOSTS=redis
fi

if [ ! ${REDIS_PORT:-} ]; then
	export REDIS_PORT=6379
fi
