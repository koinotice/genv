#!/usr/bin/env bash

if [ ! ${TRAEFIK_ACME:-} ]; then
	export PORTAINER_HOSTS=portainer.harpoon.dev
fi

if [ ${CUSTOM_DOMAINS:-} ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export PORTAINER_HOSTS+=",portainer.${i}"
	done
fi