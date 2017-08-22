#!/usr/bin/env bash

case "${command}" in
	mysql:client) ## [<arg>...] %% MySQL Client
		${DOCKER_COMPOSE_EXEC} mysql mysql -uroot -p${MYSQL_ROOT_PASSWORD} "${args}" ;;
	*)
		service_help mysql
esac
