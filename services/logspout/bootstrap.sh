#!/usr/bin/env bash

#% 🔺 LOGSPOUT_VERSION %% Logspout Docker image version %% master
if [ ! -v LOGSPOUT_VERSION ]; then
	export LOGSPOUT_VERSION=master
fi

if [ ! -v TRAEFIK_ACME ]; then
	export LOGSPOUT_HOSTS=logspout.genv
fi

if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export LOGSPOUT_HOSTS+=",logspout.${i}"
	done
fi
