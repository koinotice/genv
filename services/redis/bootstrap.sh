#!/usr/bin/env bash

set -euo pipefail

if [ ! ${REDIS_VERSION:-} ]; then
	export REDIS_VERSION=3.0-alpine
fi

if [ ! ${REDIS_PORT:-} ]; then
	export REDIS_PORT=6379
fi