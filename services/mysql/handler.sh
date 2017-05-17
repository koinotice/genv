#!/usr/bin/env bash

set -euo pipefail

case "${command:-}" in
	mysql:client) ## [<arg>...] %% MySQL Client
		docker-compose ${SERVICE_COMPOSE_FILE} exec mysql mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${args} ;;
esac
