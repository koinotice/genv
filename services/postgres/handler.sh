#!/usr/bin/env bash

set -euo pipefail

case "${command:-}" in
	postgres:psql) ## [<arg>...] %% Postgres PSQL
		${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} exec postgres psql -U ${POSTGRES_USER} "${args}" ;;
	*)
		service_help postgres;;
esac
