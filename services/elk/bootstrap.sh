#!/usr/bin/env bash

set -euo pipefail

# ELK hostnames
export ELK_HOSTS=elk.harpoon.dev,kibana.harpoon.dev

if [ ${CUSTOM_DOMAIN} ]; then
	export ELK_HOSTS+=",elk.${CUSTOM_DOMAIN},kibana.${CUSTOM_DOMAIN}"
fi
