#!/usr/bin/env bash

case "${command}" in
	mysql:client) ## [<arg>...] %% MySQL Client
		$(serviceDockerComposeExec mysql) mysql mysql -uroot -p${MYSQL_ROOT_PASSWORD} "${args}" ;;
	*)
		serviceHelp mysql
esac
