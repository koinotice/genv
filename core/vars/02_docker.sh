#!/usr/bin/env bash

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

printDebug "HARPOON_IMAGE: $HARPOON_IMAGE"

# loopback alias ip
if [ ! -v LOOPBACK_ALIAS_IP ]; then
	export LOOPBACK_ALIAS_IP="10.254.253.1"
fi

printDebug "LOOPBACK_ALIAS_IP: $LOOPBACK_ALIAS_IP"

# docker network
if [ ! -v HARPOON_DOCKER_NETWORK ]; then
	export HARPOON_DOCKER_NETWORK="harpoon"
fi

printDebug "HARPOON_DOCKER_NETWORK: $HARPOON_DOCKER_NETWORK"

# docker subnet
export HARPOON_DIND_DOCKER_SUBNET="10.254.252.0/24"

if [ ! -v HARPOON_DOCKER_SUBNET ]; then
	if [ -v RUNNING_IN_CONTAINER ]; then
		export HARPOON_DOCKER_SUBNET=${HARPOON_DIND_DOCKER_SUBNET}
	else
		export HARPOON_DOCKER_SUBNET="10.254.254.0/24"
	fi
fi

printDebug "HARPOON_DOCKER_SUBNET: $HARPOON_DOCKER_SUBNET"

# core service container ips
harpoon_docker_net_prefix=$(echo ${HARPOON_DOCKER_SUBNET} | awk -F "/" '{print $1}' | awk -F "." '{printf "%d.%d.%d", $1, $2, $3}')

if [ ! -v HARPOON_DNSMASQ_IP ]; then
	export HARPOON_DNSMASQ_IP="${harpoon_docker_net_prefix}.254"
fi

if [ ! -v HARPOON_TRAEFIK_IP ]; then
	export HARPOON_TRAEFIK_IP="${harpoon_docker_net_prefix}.253"
fi

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
	if [ -v RUNNING_IN_CONTAINER ]; then
		export HARPOON_DOCKER_HOST_IP=${HARPOON_TRAEFIK_IP}
	else
		export HARPOON_DOCKER_HOST_IP=${LOOPBACK_ALIAS_IP}
	fi
fi

printDebug "HARPOON_DOCKER_HOST_IP: $HARPOON_DOCKER_HOST_IP"

# docker / dind
DOCKER_RUN_ARGS="--rm -v $PWD:$PWD -w $PWD --net=${HARPOON_DOCKER_NETWORK} -e 'TERM=xterm' -e USER_UID -e USER_GID"

export SOCK=/var/run/docker.sock

export DIND_EXEC="docker exec ${COMPOSE_PROJECT_NAME}_dind"
export DIND_EXEC_TTY="docker exec -t ${COMPOSE_PROJECT_NAME}_dind"
export DIND_EXEC_IT="docker exec -it ${COMPOSE_PROJECT_NAME}_dind"

export DOCKER_COMPOSE_CMD="docker-compose"

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

printDebug "DOCKER_RUN: $DOCKER_RUN"

if [ -f "${DOCKER_INHERIT_ENV_FILE:-}" ]; then
	printDebug "Docker will inherit environment from ${DOCKER_INHERIT_ENV_FILE}"
	export DOCKER_RUN_WITH_ENV="${DOCKER_RUN} --env-file ${TASKS_ROOT}/docker/inherit.env --env-file ${DOCKER_INHERIT_ENV_FILE}"
else
	export DOCKER_RUN_WITH_ENV="${DOCKER_RUN} --env-file ${TASKS_ROOT}/docker/inherit.env"
fi

export HARPOON_DOCKER_COMPOSE_CFG="${HARPOON_ROOT}/docker-compose.yml"
export HARPOON_DOCKER_COMPOSE="docker-compose -p harpoon -f ${HARPOON_DOCKER_COMPOSE_CFG}"

# app container command execution
if [ ! -v CI ]
then
	if [ -f "docker-compose.dev.yml" ]; then
		export DOCKER_COMPOSE_DEV="docker-compose -f docker-compose.yml -f docker-compose.dev.yml"
	else
		export DOCKER_COMPOSE_DEV="docker-compose"
	fi
	export EXEC="${DOCKER_COMPOSE_DEV} exec ${PROJECT}"
else
	export DOCKER_COMPOSE_DEV="docker-compose"
	export EXEC="${DOCKER_COMPOSE_DEV} exec -T ${PROJECT}"
fi

loadDynamicEnv() {
	if [ -f "${DOCKER_DYNAMIC_ENV_FILE:-}" ]; then
		printDebug "Loading environment variables from ${DOCKER_DYNAMIC_ENV_FILE}..."
		source ${DOCKER_DYNAMIC_ENV_FILE}
	fi
}

# $1 IMAGE
# $2 ARGS
dockerRunWithDynamicEnv() {
	configDockerNetwork

	loadDynamicEnv

	printDebug "EXECUTING: ${DOCKER_RUN_WITH_ENV} $1 $2..."

	${DOCKER_RUN_WITH_ENV} $1 $2
}

# DEPRECATED
docker_run_with_dynamic_env() {
	printWarn "docker_run_with_dynamic_env() is deprecated. Please use dockerRunWithDynamicEnv()."
	dockerRunWithDynamicEnv $1 $2
}

dockerRun() {
	configDockerNetwork

	printDebug "EXECUTING: ${DOCKER_RUN} $@"

	${DOCKER_RUN} $@
}

# DEPRECATED
docker_run() {
	printWarn "docker_run() is deprecated. Please use dockerRun()."
	dockerRun $@
}