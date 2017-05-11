#!/usr/bin/env bash

set -e

if [ ! ${MYSQL_VERSION} ]; then
	export MYSQL_VERSION=5
fi

if [ ! ${MYSQL_ROOT_PASSWORD} ]; then
	export MYSQL_ROOT_PASSWORD="abc123"
fi

if [ ! ${MYSQL_DATABASE} ]; then
	export MYSQL_DATABASE="lowcal"
fi

if [ ! ${MYSQL_PORT} ]; then
	export MYSQL_PORT=3306
	export PRIVATE_PORT=${MYSQL_PORT}
fi