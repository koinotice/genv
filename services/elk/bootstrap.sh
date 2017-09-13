#!/usr/bin/env bash

# ELK hostnames
if [ ! -v TRAEFIK_ACME ]; then
	export ELK_HOSTS=elk.harpoon.dev,kibana.harpoon.dev
fi

if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export ELK_HOSTS+=",elk.${i},kibana.${i}"
	done
fi