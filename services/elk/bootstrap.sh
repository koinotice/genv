#!/usr/bin/env bash

set -euo pipefail

# ELK hostnames
export ELK_HOSTS=elk.harpoon.dev,kibana.harpoon.dev

if [ ${CUSTOM_DOMAINS:-} ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export ELK_HOSTS+=",elk.${i},kibana.${i}"
	done
fi