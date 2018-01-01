#!/usr/bin/env bash

if [ ! -v TRAEFIK_ACME ]; then
	export PORTAINER_HOSTS=portainer.harpoon
fi

if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export PORTAINER_HOSTS+=",portainer.${i}"
	done
fi