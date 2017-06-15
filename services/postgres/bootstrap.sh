#!/usr/bin/env bash

set -euo pipefail

if [ ! ${POSTGRES_VERSION:-} ]; then
	export POSTGRES_VERSION=9-alpine
fi

if [ ! ${POSTGRES_USER:-} ]; then
	export POSTGRES_USER="harpoon"
fi

if [ ! ${POSTGRES_PASSWORD:-} ]; then
	export POSTGRES_PASSWORD="abc123"
fi

if [ ! ${POSTGRES_PORT:-} ]; then
	export POSTGRES_PORT=5432
	export PRIVATE_PORT=${POSTGRES_PORT}
fi

export POSTGRES_VOLUME_NAME=pgdata

postgres_pre_up() {
	VOLUME_CREATED=$(docker volume ls | grep ${POSTGRES_VOLUME_NAME}) || true

	if [[ ! ${VOLUME_CREATED} ]]; then
		echo -e "${PURPLE}Creating docker volume named '${POSTGRES_VOLUME_NAME}'...${NC}"
		docker volume create --name=${POSTGRES_VOLUME_NAME} || true
	fi
}

postgres_remove_volume() {
	VOLUME_CREATED=$(docker volume ls | grep ${POSTGRES_VOLUME_NAME}) || true

	if [[ ${VOLUME_CREATED} ]]; then
		echo -e "${PURPLE}Removing docker volume named '${POSTGRES_VOLUME_NAME}'...${NC}"
		docker volume rm ${POSTGRES_VOLUME_NAME} || true
	fi
}

postgres_post_destroy() {
	postgres_remove_volume
}

postgres_post_clean() {
	postgres_remove_volume
}