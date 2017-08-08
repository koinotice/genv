#!/usr/bin/env bash

if [ ! -v MYSQL_VERSION ]; then
	export MYSQL_VERSION=5
fi

if [ ! -v MYSQL_ROOT_PASSWORD ]; then
	export MYSQL_ROOT_PASSWORD="abc123"
fi

if [ ! -v MYSQL_DATABASE ]; then
	export MYSQL_DATABASE="harpoon"
fi

if [ ! -v MYSQL_PORT ]; then
	export MYSQL_PORT=3306
	export PRIVATE_PORT=${MYSQL_PORT}
fi

export MYSQL_VOLUME_NAME=mysql

mysql_pre_up() {
	VOLUME_CREATED=$(docker volume ls | grep ${MYSQL_VOLUME_NAME}) || true

	if [[ "${VOLUME_CREATED}" == "" ]]; then
		print_info "Creating docker volume named '${MYSQL_VOLUME_NAME}'..."
		docker volume create --name=${MYSQL_VOLUME_NAME}
	fi
}

mysql_remove_volume() {
	VOLUME_CREATED=$(docker volume ls | grep ${MYSQL_VOLUME_NAME}) || true

	if [[ "${VOLUME_CREATED}" != "" ]]; then
		print_info "Removing docker volume named '${MYSQL_VOLUME_NAME}'..."
		docker volume rm ${MYSQL_VOLUME_NAME}
	fi
}

mysql_post_destroy() {
	mysql_remove_volume
}

mysql_post_clean() {
	mysql_remove_volume
}