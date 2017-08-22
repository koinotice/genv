#!/usr/bin/env bash

case "${command}" in
	postgres:psql) ## [<arg>...] %% Postgres PSQL
		${DOCKER_COMPOSE_EXEC} postgres psql -U ${POSTGRES_USER} "${args}" ;;
	*)
		service_help postgres
esac
