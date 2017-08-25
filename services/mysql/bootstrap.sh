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
	local volumeCreated=$(docker volume ls | grep ${MYSQL_VOLUME_NAME}) || true

	if [[ "${volumeCreated}" == "" ]]; then
		printInfo "Creating docker volume named '${MYSQL_VOLUME_NAME}'..."
		docker volume create --name=${MYSQL_VOLUME_NAME}
	fi
}

mySQLRemoveVolume() {
	local volumeCreated=$(docker volume ls | grep ${MYSQL_VOLUME_NAME}) || true

	if [[ "${volumeCreated}" != "" ]]; then
		printInfo "Removing docker volume named '${MYSQL_VOLUME_NAME}'..."
		docker volume rm ${MYSQL_VOLUME_NAME}
	fi
}

mysql_post_destroy() {
	mySQLRemoveVolume
}

mysql_post_clean() {
	mySQLRemoveVolume
}