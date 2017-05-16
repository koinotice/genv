#!/usr/bin/env bash

set -e

# docker-machine detection
if [ -x "$(command -v docker-machine)" ]; then
	export DOCKER_MACHINE_IP=$(docker-machine ip $(docker-machine ls | grep \* | awk '{ print $1 }'))
fi

if [ ${DOCKER_MACHINE_IP} ]; then
	export NAMESERVER_IP=${DOCKER_MACHINE_IP}
else
	export NAMESERVER_IP="127.0.0.1"
fi

source ${HARPOON_ROOT}/core/vars/traefik.sh