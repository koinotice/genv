#!/usr/bin/env bash

# Mailhog hostnames
if [ ! ${TRAEFIK_ACME:-} ]; then
	export MH_HOSTS=mailhog.harpoon.dev
fi

if [ ${CUSTOM_DOMAINS:-} ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export MH_HOSTS+=",mailhog.${i}"
	done
fi