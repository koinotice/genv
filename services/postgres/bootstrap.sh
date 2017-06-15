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

postgres_pre_up() {
	echo -e "${PURPLE}Creating docker volume named 'pgdata'...${NC}"
	docker volume create --name=pgdata || true
}

postgres_remove_volume() {
	echo -e "${PURPLE}Removing docker volume named 'pgdata'...${NC}"
	docker volume rm pgdata || true
}

postgres_post_destroy() {
	postgres_remove_volume
}

postgres_post_clean() {
	postgres_remove_volume
}