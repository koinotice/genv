#!/usr/bin/env bash

set -euo pipefail

if [ ! ${POSTGRES_VERSION:-} ]; then
	export POSTGRES_VERSION=9-alpine
fi

if [ ! ${POSTGRES_USER:-} ]; then
	export POSTGRES_USER="harpoon"
fi

if [ ! ${POSTGRES_PASSWORD:-} ]; then
	export POSTGRES_PASSWORD="abc123"
fi

if [ ! ${POSTGRES_PORT:-} ]; then
	export POSTGRES_PORT=5432
	export PRIVATE_PORT=${POSTGRES_PORT}
fi