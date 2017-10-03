#!/usr/bin/env bash

if [[ -f /.dockerenv || -f /.harpoon-container ]]; then
	export RUNNING_IN_CONTAINER=true
fi

#% 🔺 USER_UID %% Current user's uid %% id -u
if [ ! -v USER_UID ]; then
	export USER_UID=$(id -u)
fi

#% 🔺 USER_GID %% Current user's gid %% id -g
if [ ! -v USER_GID ]; then
	export USER_GID=$(id -g)
fi

#% 🔺 HARPOON_IMAGE %% Harpoon Docker image %% wheniwork/harpoon
if [ ! -v HARPOON_IMAGE ]; then
	export HARPOON_IMAGE=wheniwork/harpoon
fi

printDebug "HARPOON_IMAGE: $HARPOON_IMAGE"

# loopback alias ip
#% 🔺 HARPOON_LOOPBACK_ALIAS_IP %% Loopback alias IP address %% 10.254.253.1
if [ ! -v HARPOON_LOOPBACK_ALIAS_IP ]; then
	export HARPOON_LOOPBACK_ALIAS_IP="10.254.253.1"
fi

printDebug "HARPOON_LOOPBACK_ALIAS_IP: $HARPOON_LOOPBACK_ALIAS_IP"

# docker network
#% 🔺 HARPOON_DOCKER_NETWORK %% Harpoon Docker network %% harpoon
if [ ! -v HARPOON_DOCKER_NETWORK ]; then
	export HARPOON_DOCKER_NETWORK="harpoon"
fi

printDebug "HARPOON_DOCKER_NETWORK: $HARPOON_DOCKER_NETWORK"

# docker subnet
#% 🔹 HARPOON_DIND_DOCKER_SUBNET %% Harpoon Docker-in-Docker (dind) subnet %% 10.254.252.0/24
export HARPOON_DIND_DOCKER_SUBNET="10.254.252.0/24"

#% 🔺 HARPOON_DOCKER_SUBNET %% Harpoon Docker subnet %% $HARPOON_DIND_DOCKER_SUBNET | 10.254.254.0/24
if [ ! -v HARPOON_DOCKER_SUBNET ]; then
	if [ -v RUNNING_IN_CONTAINER ]; then
		export HARPOON_DOCKER_SUBNET=${HARPOON_DIND_DOCKER_SUBNET}
	else
		export HARPOON_DOCKER_SUBNET="10.254.254.0/24"
	fi
fi

printDebug "HARPOON_DOCKER_SUBNET: $HARPOON_DOCKER_SUBNET"

# core service container ips
dockerNetPrefix=$(echo ${HARPOON_DOCKER_SUBNET} | awk -F "/" '{print $1}' | awk -F "." '{printf "%d.%d.%d", $1, $2, $3}')

#% 🔺 HARPOON_DNSMASQ_IP %% dnsmasq container IP address %% 10.254.254.254
if [ ! -v HARPOON_DNSMASQ_IP ]; then
	export HARPOON_DNSMASQ_IP="${dockerNetPrefix}.254"
fi

#% 🔺 HARPOON_TRAEFIK_IP %% Traefik container IP address %% 10.254.254.253
if [ ! -v HARPOON_TRAEFIK_IP ]; then
	export HARPOON_TRAEFIK_IP="${dockerNetPrefix}.253"
fi

# core service hostnames
if [ ! -v TRAEFIK_ACME ]; then
	export CONSUL_HOSTS=consul.harpoon.dev
	export TRAEFIK_HOSTS=traefik.harpoon.dev
fi

#% 🔺 CUSTOM_DOMAINS %% Array of custom domain names
if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export CONSUL_HOSTS+=",consul.${i}"
		export TRAEFIK_HOSTS+=",traefik.${i}"
	done
fi

# docker-machine detection
#% 🔹 HARPOON_DOCKER_MACHINE_IP %% Current/default Docker Machine IP address
if [ -x "$(command -v docker-machine)" ]; then
	export HARPOON_DOCKER_MACHINE_IP=$(docker-machine ip $(docker-machine ls | grep \* | awk '{ print $1 }'))
fi

#% 🔹 HARPOON_DOCKER_HOST_IP %% Docker host IP address %% DOCKER_MACHINE_IP | TRAEFIK_IP | LOOPBACK_ALIAS_IP
if [ -v HARPOON_DOCKER_MACHINE_IP ]; then
	export HARPOON_DOCKER_HOST_IP=${HARPOON_DOCKER_MACHINE_IP}
else
	if [ -v RUNNING_IN_CONTAINER ]; then
		export HARPOON_DOCKER_HOST_IP=${HARPOON_TRAEFIK_IP}
	else
		export HARPOON_DOCKER_HOST_IP=${HARPOON_LOOPBACK_ALIAS_IP}
	fi
fi

printDebug "HARPOON_DOCKER_HOST_IP: $HARPOON_DOCKER_HOST_IP"

# docker / dind
dockerRunArgs="--rm -v $PWD:$PWD -w $PWD --net=${HARPOON_DOCKER_NETWORK} -e 'TERM=xterm' -e USER_UID -e USER_GID ${HARPOON_DOCKER_ADDITIONAL_RUN_ARGS:-}"

dockerSock=/var/run/docker.sock

#% 🔹 HARPOON_DIND_EXEC %% DinD exec command %% docker exec ${COMPOSE_PROJECT_NAME}_dind
export HARPOON_DIND_EXEC="docker exec ${COMPOSE_PROJECT_NAME}_dind"

#% 🔹 HARPOON_DIND_EXEC_TTY %% DinD TTY-only exec command %% docker exec -t ${COMPOSE_PROJECT_NAME}_dind
export HARPOON_DIND_EXEC_TTY="docker exec -t ${COMPOSE_PROJECT_NAME}_dind"

#% 🔹 HARPOON_DIND_EXEC_IT %% DinD interactive exec command %% docker exec -it ${COMPOSE_PROJECT_NAME}_dind
export HARPOON_DIND_EXEC_IT="docker exec -it ${COMPOSE_PROJECT_NAME}_dind"

#% 🔹 HARPOON_DOCKER_COMPOSE_CMD %% Docker Compose command %% docker-compose
export HARPOON_DOCKER_COMPOSE_CMD="docker-compose"

if [ -f ${dockerSock} ]; then
	# local docker server
	export DOCKER_HOST=unix://${dockerSock}
	DOCKER_RUN="docker run ${dockerRunArgs} -v ${dockerSock}:${dockerSock}"

	if [ -d "${HOME}/.docker" ]; then
		DOCKER_RUN+=" -v ${HOME}/.docker:/root/.docker"
	fi
else
	# remote docker server
	DOCKER_RUN="docker run ${dockerRunArgs}"

	if [ -d "${HOME}/.docker" ]; then
		DOCKER_RUN+=" -v ${HOME}/.docker:/root/.docker"
	fi
fi

#% 🔹 DOCKER_RUN %% Docker run command template
export DOCKER_RUN

printDebug "DOCKER_RUN: $DOCKER_RUN"

if [ -f "${DOCKER_INHERIT_ENV_FILE:-}" ]; then
	printDebug "Docker will inherit environment from ${DOCKER_INHERIT_ENV_FILE}"
	export DOCKER_RUN_WITH_ENV="${DOCKER_RUN} --env-file ${HARPOON_TASKS_ROOT}/docker/inherit.env --env-file ${DOCKER_INHERIT_ENV_FILE}"
else
	export DOCKER_RUN_WITH_ENV="${DOCKER_RUN} --env-file ${HARPOON_TASKS_ROOT}/docker/inherit.env"
fi

#% 🔹 HARPOON_DOCKER_COMPOSE_CFG %% Path to Harpoon core docker-compose.yml %% ${HARPOON_ROOT}/docker-compose.yml
export HARPOON_DOCKER_COMPOSE_CFG="${HARPOON_ROOT}/docker-compose.yml"

#% 🔹 HARPOON_DOCKER_COMPOSE %% Harpoon Core Docker Compose command template
export HARPOON_DOCKER_COMPOSE="docker-compose -p harpoon -f ${HARPOON_DOCKER_COMPOSE_CFG}"

# app container command execution
#% 🔹 DOCKER_COMPOSE_DEV %% Docker Compose command template for local development with Harpoon
#% 🔹 EXEC %% Docker Compose exec command template for local development and CI with Harpoon
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

	${DOCKER_RUN} "$@"
}

# DEPRECATED
docker_run() {
	printWarn "docker_run() is deprecated. Please use dockerRun()."
	dockerRun "$@"
}
