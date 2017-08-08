#!/usr/bin/env bash

if [ ! ${TRAEFIK_ACME:-} ]; then
	export CADVISOR_HOSTS=cadvisor.harpoon.dev
fi

if [ ${CUSTOM_DOMAINS:-} ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export CADVISOR_HOSTS+=",cadvisor.${i}"
	done
fi