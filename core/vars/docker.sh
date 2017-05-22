#!/usr/bin/env bash

set -euo pipefail

# docker-machine detection
if [ -x "$(command -v docker-machine)" ]; then
	export DOCKER_MACHINE_IP=$(docker-machine ip $(docker-machine ls | grep \* | awk '{ print $1 }'))
fi

if [ ${DOCKER_MACHINE_IP:-} ]; then
	export NAMESERVER_IP=${DOCKER_MACHINE_IP}
else
	export NAMESERVER_IP="127.0.0.1"
fi

# docker-compose
export DOCKER_COMPOSE_CMD="docker-compose -p harpoon"
export HARPOON_DOCKER_COMPOSE_CFG="${HARPOON_ROOT}/docker-compose.yml"
export HARPOON_DOCKER_COMPOSE="${DOCKER_COMPOSE_CMD} -f ${HARPOON_DOCKER_COMPOSE_CFG}"

# docker network
if [ ! ${HARPOON_DOCKER_NETWORK:-} ]; then
	export HARPOON_DOCKER_NETWORK="harpoon"
fi

# core service hostnames
export CADVISOR_HOSTS=cadvisor.harpoon.dev
export CONSUL_HOSTS=consul.harpoon.dev
export TRAEFIK_HOSTS=traefik.harpoon.dev

if [ ${CUSTOM_DOMAINS:-} ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export CADVISOR_HOSTS+=",cadvisor.${i}"
		export CONSUL_HOSTS+=",consul.${i}"
		export TRAEFIK_HOSTS+=",traefik.${i}"
	done
fi