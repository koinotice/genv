#!/usr/bin/env bash

set -euo pipefail

# Mailhog hostnames
export MH_HOSTS=mailhog.harpoon.dev

if [ ${CUSTOM_DOMAIN} ]; then
	export MH_HOSTS+=",mailhog.${CUSTOM_DOMAIN}"
fi
