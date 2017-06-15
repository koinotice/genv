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

mysql_pre_up() {
	echo -e "${PURPLE}Creating docker volume named 'mysql'...${NC}"
	docker volume create --name=mysql || true
}

mysql_remove_volume() {
	echo -e "${PURPLE}Removing docker volume named 'mysql'...${NC}"
	docker volume rm mysql || true
}

mysql_post_destroy() {
	mysql_remove_volume
}

mysql_post_clean() {
	mysql_remove_volume
}