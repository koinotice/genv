#!/usr/bin/env bash

# Mailhog hostnames
if [ ! -v TRAEFIK_ACME ]; then
	export MH_HOSTS=mailhog.harpoon.dev
fi

if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export MH_HOSTS+=",mailhog.${i}"
	done
fi