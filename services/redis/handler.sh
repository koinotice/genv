#!/usr/bin/env bash

case "${command}" in
	redis:cli) ## [<arg>...] %% Redis CLI
		${DOCKER_COMPOSE_EXEC} redis redis-cli ${args} ;;
	*)
		serviceHelp redis
esac
