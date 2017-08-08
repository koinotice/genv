#!/usr/bin/env bash

case "${command:-}" in
	redis:cli) ## [<arg>...] %% Redis CLI
		${DOCKER_COMPOSE_EXEC} redis redis-cli ${args} ;;
	*)
		service_help redis
esac
