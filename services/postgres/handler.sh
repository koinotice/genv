#!/usr/bin/env bash

case "${command}" in
	postgres:psql) ## [<arg>...] %% Postgres PSQL
		$(serviceDockerComposeExec postgres) postgres psql -U ${POSTGRES_USER} "${args}" ;;
	*)
		serviceHelp postgres
esac
