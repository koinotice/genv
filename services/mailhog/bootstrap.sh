#!/usr/bin/env bash

set -euo pipefail

# Mailhog hostnames
export MH_HOSTS=mailhog.harpoon.dev

if [ ${CUSTOM_DOMAINS:-} ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export MH_HOSTS+=",mailhog.${i}"
	done
fi