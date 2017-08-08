#!/usr/bin/env bash

# ELK hostnames
if [ ! ${TRAEFIK_ACME:-} ]; then
	export ELK_HOSTS=elk.harpoon.dev,kibana.harpoon.dev
fi

if [ ${CUSTOM_DOMAINS:-} ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export ELK_HOSTS+=",elk.${i},kibana.${i}"
	done
fi