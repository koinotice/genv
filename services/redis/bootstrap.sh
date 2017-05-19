#!/usr/bin/env bash

set -euo pipefail

if [ ! ${REDIS_VERSION:-} ]; then
	export REDIS_VERSION=alpine
fi

if [ ! ${REDIS_PORT:-} ]; then
	export REDIS_PORT=6379
fi