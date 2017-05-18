#!/usr/bin/env bash

set -euo pipefail

if [ ! ${LOCALSTACK_SERVICES:-} ]; then
	export LOCALSTACK_SERVICES=""
fi

if [ ! ${PORT_MAPPINGS:-} ]; then
	export PORT_MAPPINGS="4567-4581:4567-4581"
#	export PORT_MAPPINGS=$(echo ${SERVICES} | sed 's/[^0-9]/ /g' | sed 's/\([0-9][0-9]*\)/-p \1:\1/g' | sed 's/  */ /g')
fi


if [ ! ${DEFAULT_REGION:-} ]; then
	export DEFAULT_REGION="us-east-1"
fi

if [ ! ${KINESIS_ERROR_PROBABILITY:-} ]; then
	export KINESIS_ERROR_PROBABILITY=0.0
fi

if [ ! ${DYNAMODB_ERROR_PROBABILITY:-} ]; then
	export DYNAMODB_ERROR_PROBABILITY=0.0
fi

export LAMBDA_EXECUTOR="docker"
export DATA_DIR="/tmp/localstack/data"
export TMP_DIR="/tmp/localstack"

# Localstack hostnames
export LS_HOSTS=localstack.harpoon.dev

if [ ${CUSTOM_DOMAIN} ]; then
	export LS_HOSTS+=",localstack.${CUSTOM_DOMAIN}"
fi


localstack_up() {
	mkdir -p ${TMP_DIR}; chmod -R 777 ${TMP_DIR}
}