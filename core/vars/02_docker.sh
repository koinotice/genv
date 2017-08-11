#!/usr/bin/env bash

get_ip() {
	ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
}

if [[ -f /.dockerenv || -f /.harpoon-container ]]; then
	export RUNNING_IN_CONTAINER=true
fi

if [ ! -v USER_UID ]; then
	export USER_UID=$(id -u)
fi

if [ ! -v USER_GID ]; then
	export USER_GID=$(id -g)
fi

if [ ! -v HARPOON_IMAGE ]; then
	export HARPOON_IMAGE=wheniwork/harpoon
fi

print_debug "HARPOON_IMAGE: $HARPOON_IMAGE"

# loopback alias ip
if [ ! -v LOOPBACK_ALIAS_IP ]; then
	export LOOPBACK_ALIAS_IP="10.254.253.1"
fi

print_debug "LOOPBACK_ALIAS_IP: $LOOPBACK_ALIAS_IP"

# docker network
if [ ! -v HARPOON_DOCKER_NETWORK ]; then
	export HARPOON_DOCKER_NETWORK="harpoon"
fi

print_debug "HARPOON_DOCKER_NETWORK: $HARPOON_DOCKER_NETWORK"

# docker subnet
if [ ! -v HARPOON_DOCKER_SUBNET ]; then
	export HARPOON_DOCKER_SUBNET="10.254.254.0/24"
fi

print_debug "HARPOON_DOCKER_SUBNET: $HARPOON_DOCKER_SUBNET"

# core service hostnames
if [ ! -v TRAEFIK_ACME ]; then
	export CONSUL_HOSTS=consul.harpoon.dev
	export TRAEFIK_HOSTS=traefik.harpoon.dev
fi

if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export CONSUL_HOSTS+=",consul.${i}"
		export TRAEFIK_HOSTS+=",traefik.${i}"
	done
fi

# docker-machine detection
if [ -x "$(command -v docker-machine)" ]; then
	export DOCKER_MACHINE_IP=$(docker-machine ip $(docker-machine ls | grep \* | awk '{ print $1 }'))
fi

if [ -v DOCKER_MACHINE_IP ]; then
	export HARPOON_DOCKER_HOST_IP=${DOCKER_MACHINE_IP}
else
	if [[ $(uname) == 'Linux' ]]; then
		if [ -v RUNNING_IN_CONTAINER ]; then
			export HARPOON_DOCKER_HOST_IP=$(get_ip)
		else
			export HARPOON_DOCKER_HOST_IP="127.0.1.1"
		fi
	else
		export HARPOON_DOCKER_HOST_IP="127.0.0.1"
	fi
fi

print_debug "HARPOON_DOCKER_HOST_IP: $HARPOON_DOCKER_HOST_IP"

# docker / dind
DOCKER_RUN_ARGS="--rm -v $PWD:$PWD -w $PWD --net=${HARPOON_DOCKER_NETWORK} -e 'TERM=xterm' -e USER_UID -e USER_GID"

export SOCK=/var/run/docker.sock

export DIND_EXEC="docker exec ${COMPOSE_PROJECT_NAME}_dind"
export DIND_EXEC_TTY="docker exec -t ${COMPOSE_PROJECT_NAME}_dind"
export DIND_EXEC_IT="docker exec -it ${COMPOSE_PROJECT_NAME}_dind"

export DOCKER_COMPOSE_CMD="docker-compose -p harpoon"

if [ -f ${SOCK} ]; then
	# local docker server
	export DOCKER_HOST=unix://${SOCK}
	DOCKER_RUN="docker run ${DOCKER_RUN_ARGS} -v ${SOCK}:${SOCK}"

	if [ -d "${HOME}/.docker" ]; then
		DOCKER_RUN+=" -v ${HOME}/.docker:/root/.docker"
	fi
else
	# remote docker server
	DOCKER_RUN="docker run ${DOCKER_RUN_ARGS}"

	if [ -d "${HOME}/.docker" ]; then
		DOCKER_RUN+=" -v ${HOME}/.docker:/root/.docker"
	fi
fi

export DOCKER_RUN

print_debug "DOCKER_RUN: $DOCKER_RUN"

if [ -f "${DOCKER_INHERIT_ENV_FILE:-}" ]; then
	print_debug "Docker will inherit environment from ${DOCKER_INHERIT_ENV_FILE}"
	export DOCKER_RUN_WITH_ENV="${DOCKER_RUN} --env-file ${MODULES_ROOT}/docker/inherit.env --env-file ${DOCKER_INHERIT_ENV_FILE}"
else
	export DOCKER_RUN_WITH_ENV="${DOCKER_RUN} --env-file ${MODULES_ROOT}/docker/inherit.env"
fi

export HARPOON_DOCKER_COMPOSE_CFG="${HARPOON_ROOT}/docker-compose.yml"
export HARPOON_DOCKER_COMPOSE="${DOCKER_COMPOSE_CMD} -f ${HARPOON_DOCKER_COMPOSE_CFG}"


# $1 IMAGE
# $2 ARGS
docker_run_with_dynamic_env() {
	config_docker_network

	if [ -f "${DOCKER_DYNAMIC_ENV_FILE:-}" ]; then
		print_debug "Loading environment variables from ${DOCKER_DYNAMIC_ENV_FILE}..."
		source ${DOCKER_DYNAMIC_ENV_FILE}
	fi

	print_debug "Running: ${DOCKER_RUN_WITH_ENV} $1 $2..."

	${DOCKER_RUN_WITH_ENV} $1 $2
}

docker_run() {
	config_docker_network

	${DOCKER_RUN} $@
}