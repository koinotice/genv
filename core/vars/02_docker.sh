#!/usr/bin/env bash

if [[ -f /.dockerenv || -f /.genv-container ]]; then
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

#% 🔺 GENV_IMAGE %% Genv Docker image %% wheniwork/genv
if [ ! -v GENV_IMAGE ]; then
	export GENV_IMAGE=koinotice/genv
fi

printDebug "GENV_IMAGE: $GENV_IMAGE"

#% 🔹 GENV_INT_DOMAIN %% Genv internal domain name %% service.int.genv
export GENV_INT_DOMAIN=service.int.genv

export GENV_DOMAIN=genv.com

printDebug "GENV_IMAGE: $GENV_IMAGE"

# loopback alias ip
#% 🔺 GENV_LOOPBACK_ALIAS_IP %% Loopback alias IP address %% 10.254.253.1
if [ ! -v GENV_LOOPBACK_ALIAS_IP ]; then
	export GENV_LOOPBACK_ALIAS_IP="10.254.253.1"
fi

printDebug "GENV_LOOPBACK_ALIAS_IP: $GENV_LOOPBACK_ALIAS_IP"

# docker network
#% 🔺 GENV_DOCKER_NETWORK %% Genv Docker network %% genv
if [ ! -v GENV_DOCKER_NETWORK ]; then
	export GENV_DOCKER_NETWORK="genv"
fi

printDebug "GENV_DOCKER_NETWORK: $GENV_DOCKER_NETWORK"

# docker subnet
#% 🔹 GENV_DIND_DOCKER_SUBNET %% Genv Docker-in-Docker (dind) subnet %% 10.254.252.0/24
export GENV_DIND_DOCKER_SUBNET="10.254.252.0/24"

#% 🔺 GENV_DOCKER_SUBNET %% Genv Docker subnet %% $GENV_DIND_DOCKER_SUBNET | 10.254.254.0/24
if [ ! -v GENV_DOCKER_SUBNET ]; then

	if [ -v RUNNING_IN_CONTAINER ]; then
		export GENV_DOCKER_SUBNET=${GENV_DIND_DOCKER_SUBNET}
	else
		export GENV_DOCKER_SUBNET="10.254.254.0/24"
	fi
fi

 echo 1${GENV_DOCKER_SUBNET}2

printDebug "GENV_DOCKER_SUBNET: $GENV_DOCKER_SUBNET"

# core service container ips
dockerNetPrefix=$(echo ${GENV_DOCKER_SUBNET} | awk -F "/" '{print $1}' | awk -F "." '{printf "%d.%d.%d", $1, $2, $3}')

#% 🔺 GENV_DNSMASQ_IP %% dnsmasq container IP address %% 10.254.254.254
if [ ! -v GENV_DNSMASQ_IP ]; then
	export GENV_DNSMASQ_IP="${dockerNetPrefix}.254"
fi

#% 🔺 GENV_CONSUL_IP %% Traefik container IP address %% 10.254.254.253
if [ ! -v GENV_CONSUL_IP ]; then
	export GENV_CONSUL_IP="${dockerNetPrefix}.253"
fi

#% 🔺 GENV_TRAEFIK_IP %% Traefik container IP address %% 10.254.254.252
if [ ! -v GENV_TRAEFIK_IP ]; then
	export GENV_TRAEFIK_IP="${dockerNetPrefix}.252"
fi

# core service hostnames
if [ ! -v TRAEFIK_ACME ]; then
	export DNSMASQ_HOSTS=dnsmasq.${GENV_DOMAIN}
	export CONSUL_HOSTS=consul.${GENV_DOMAIN}
	export TRAEFIK_HOSTS=traefik.${GENV_DOMAIN}
fi

#% 🔺 CUSTOM_DOMAINS %% Array of custom domain names
if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export DNSMASQ_HOSTS+=",dnsmasq.${i}"
		export CONSUL_HOSTS+=",consul.${i}"
		export TRAEFIK_HOSTS+=",traefik.${i}"
	done
fi

# docker-machine detection
#% 🔹 GENV_DOCKER_MACHINE_IP %% Current/default Docker Machine IP address
if [ -x "$(command -v docker-machine)" ]; then
	export GENV_DOCKER_MACHINE_IP=$(docker-machine ip $(docker-machine ls | grep \* | awk '{ print $1 }'))
fi

#% 🔹 GENV_DOCKER_HOST_IP %% Docker host IP address %% DOCKER_MACHINE_IP | TRAEFIK_IP | LOOPBACK_ALIAS_IP
if [ -v GENV_DOCKER_MACHINE_IP ]; then
	export GENV_DOCKER_HOST_IP=${GENV_DOCKER_MACHINE_IP}
else
	if [ -v RUNNING_IN_CONTAINER ]; then
		export GENV_DOCKER_HOST_IP="127.0.0.1"
	else
		export GENV_DOCKER_HOST_IP=${GENV_LOOPBACK_ALIAS_IP}
	fi
fi

printDebug "GENV_DOCKER_HOST_IP: $GENV_DOCKER_HOST_IP"

if (timeout 1 bash -c "</dev/tcp/${GENV_DNSMASQ_IP}/53") 2>/dev/null ; then
		GENV_DOCKER_DNS_ARG="--dns ${GENV_DNSMASQ_IP}"
fi

printDebug "GENV_DOCKER_DNS_ARG: ${GENV_DOCKER_DNS_ARG:-}"

# docker / dind
dockerRunArgs="--rm -v $PWD:$PWD -w $PWD --net=${GENV_DOCKER_NETWORK} ${GENV_DOCKER_DNS_ARG:-} -e 'TERM=xterm' -e USER_UID -e USER_GID ${GENV_DOCKER_ADDITIONAL_RUN_ARGS:-}"

dockerSock=/var/run/docker.sock

#% 🔹 GENV_DIND_EXEC %% DinD exec command %% docker exec ${COMPOSE_PROJECT_NAME}_dind
export GENV_DIND_EXEC="docker exec ${COMPOSE_PROJECT_NAME}_dind"

#% 🔹 GENV_DIND_EXEC_TTY %% DinD TTY-only exec command %% docker exec -t ${COMPOSE_PROJECT_NAME}_dind
export GENV_DIND_EXEC_TTY="docker exec -t ${COMPOSE_PROJECT_NAME}_dind"

#% 🔹 GENV_DIND_EXEC_IT %% DinD interactive exec command %% docker exec -it ${COMPOSE_PROJECT_NAME}_dind
export GENV_DIND_EXEC_IT="docker exec -it ${COMPOSE_PROJECT_NAME}_dind"

#% 🔹 GENV_DOCKER_COMPOSE_CMD %% Docker Compose command %% docker-compose
export GENV_DOCKER_COMPOSE_CMD="docker-compose"

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
	export DOCKER_RUN_WITH_ENV="${DOCKER_RUN} --env-file ${GENV_TASKS_ROOT}/docker/inherit.env --env-file ${DOCKER_INHERIT_ENV_FILE}"
else
	export DOCKER_RUN_WITH_ENV="${DOCKER_RUN} --env-file ${GENV_TASKS_ROOT}/docker/inherit.env"
fi

#% 🔹 GENV_DOCKER_COMPOSE_CFG %% Path to Genv core docker-compose.yml %% ${GENV_ROOT}/docker-compose.yml
export GENV_DOCKER_COMPOSE_CFG="${GENV_ROOT}/docker-compose.yml"

#% 🔹 GENV_DOCKER_COMPOSE %% Genv Core Docker Compose command template
export GENV_DOCKER_COMPOSE="docker-compose -p genv -f ${GENV_DOCKER_COMPOSE_CFG}"

# app container command execution
#% 🔹 DOCKER_COMPOSE_DEV %% Docker Compose command template for local development with Genv
#% 🔹 EXEC %% Docker Compose exec command template for local development and CI with Genv
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
