#!/usr/bin/env bash

set -euo pipefail

if [ ! ${MYSQL_VERSION:-} ]; then
	export MYSQL_VERSION=5
fi

if [ ! ${MYSQL_ROOT_PASSWORD:-} ]; then
	export MYSQL_ROOT_PASSWORD="abc123"
fi

if [ ! ${MYSQL_DATABASE:-} ]; then
	export MYSQL_DATABASE="harpoon"
fi

if [ ! ${MYSQL_PORT:-} ]; then
	export MYSQL_PORT=3306
	export PRIVATE_PORT=${MYSQL_PORT}
fi

export MYSQL_VOLUME_NAME=mysql

mysql_pre_up() {
	VOLUME_CREATED=$(docker volume ls | grep ${MYSQL_VOLUME_NAME}) || true

	if [[ ! ${VOLUME_CREATED} ]]; then
		echo -e "${PURPLE}Creating docker volume named '${MYSQL_VOLUME_NAME}'...${NC}"
		docker volume create --name=${MYSQL_VOLUME_NAME}
	fi
}

mysql_remove_volume() {
	VOLUME_CREATED=$(docker volume ls | grep ${MYSQL_VOLUME_NAME}) || true

	if [[ ${VOLUME_CREATED} ]]; then
		echo -e "${PURPLE}Removing docker volume named '${MYSQL_VOLUME_NAME}'...${NC}"
		docker volume rm ${MYSQL_VOLUME_NAME}
	fi
}

mysql_post_destroy() {
	mysql_remove_volume
}

mysql_post_clean() {
	mysql_remove_volume
}