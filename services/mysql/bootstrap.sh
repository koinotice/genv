#!/usr/bin/env bash

#% 🔺 MYSQL_VERSION %% MySQL Docker image version %% 5
if [ ! -v MYSQL_VERSION ]; then
	export MYSQL_VERSION=5
fi

#% 🔺 MYSQL_ROOT_PASSWORD %% MySQL root password %% abc123
if [ ! -v MYSQL_ROOT_PASSWORD ]; then
	export MYSQL_ROOT_PASSWORD="abc123"
fi

#% 🔺 MYSQL_DATABASE %% MySQL database name %% harpoon
if [ ! -v MYSQL_DATABASE ]; then
	export MYSQL_DATABASE="harpoon"
fi

#% 🔺 MYSQL_PORT %% MySQL TCP port %% 3306
if [ ! -v MYSQL_PORT ]; then
	export MYSQL_PORT=3306
	export PRIVATE_PORT=${MYSQL_PORT}
fi

#% 🔹 MYSQL_VOLUME_NAME %% MySQL Docker volume name %% mysql
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