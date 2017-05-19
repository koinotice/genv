#!/usr/bin/env bash

set -euo pipefail

case "${command:-}" in
	redis:cli) ## [<arg>...] %% Redis CLI
		${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} exec redis redis-cli ${args} ;;
	*)
		service_help redis;;
esac
