#!/usr/bin/env bash

set -euo pipefail

case "${command:-}" in
	redis:cli) ## [<arg>...] %% Redis CLI
		docker-compose ${DKR_COMPOSE_FILE} exec redis redis-cli ${args} ;;
	*)
		service_help redis;;
esac
