#!/usr/bin/env bash

#% 🔺 POSTGRES_VERSION %% Postgres Docker image version %% 9-alpine
if [ ! -v POSTGRES_VERSION ]; then
	export POSTGRES_VERSION=9-alpine
fi

#% 🔺 POSTGRES_USER %% Postgres user %% genv
if [ ! -v POSTGRES_USER ]; then
	export POSTGRES_USER="genv"
fi

#% 🔺 POSTGRES_PASSWORD %% Postgres password %% abc123
if [ ! -v POSTGRES_PASSWORD ]; then
	export POSTGRES_PASSWORD="root"
fi

#% 🔺 POSTGRES_PORT %% Postgres TCP port %% 5432
if [ ! -v POSTGRES_PORT ]; then
	export POSTGRES_PORT=5432
	export PRIVATE_PORT=${POSTGRES_PORT}
fi

#% 🔹 POSTGRES_VOLUME_NAME %% Postgres Docker volume name %% pgdata
export POSTGRES_VOLUME_NAME=pgdata

postgres_pre_up() {
	local volumeCreated=$(docker volume ls | grep ${POSTGRES_VOLUME_NAME}) || true

	if [[ "${volumeCreated}" == "" ]]; then
		printInfo "Creating docker volume named '${POSTGRES_VOLUME_NAME}'..."
		docker volume create --name=${POSTGRES_VOLUME_NAME}
	fi
}

postgresRemoveVolume() {
	local volumeCreated=$(docker volume ls | grep ${POSTGRES_VOLUME_NAME}) || true

	if [[ "${volumeCreated}" != "" ]]; then
		printInfo "Removing docker volume named '${POSTGRES_VOLUME_NAME}'..."
		docker volume rm ${POSTGRES_VOLUME_NAME}
	fi
}

postgres_post_destroy() {
	postgresRemoveVolume
}

postgres_post_clean() {
	postgresRemoveVolume
}