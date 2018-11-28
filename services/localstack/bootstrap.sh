#!/usr/bin/env bash

#% 🔺 LOCALSTACK_SERVICES %% LocalStack services %% all
if [ ! -v LOCALSTACK_SERVICES ]; then
	export LOCALSTACK_SERVICES=""
fi

#% 🔺 PORT_MAPPINGS %% LocalStack container port mappings %% 4567-4582:4567-4582
if [ ! -v PORT_MAPPINGS ]; then
	export PORT_MAPPINGS="4567-4582:4567-4582"
#	export PORT_MAPPINGS=$(echo ${SERVICES} | sed 's/[^0-9]/ /g' | sed 's/\([0-9][0-9]*\)/-p \1:\1/g' | sed 's/  */ /g')
fi

#% 🔺 DEFAULT_REGION %% Default AWS region %% us-east-1
if [ ! -v DEFAULT_REGION ]; then
	export DEFAULT_REGION="us-east-1"
fi

#% 🔺 KINESIS_ERROR_PROBABILITY %% Kinesis error probability %% 0.0
if [ ! -v KINESIS_ERROR_PROBABILITY ]; then
	export KINESIS_ERROR_PROBABILITY=0.0
fi

#% 🔺 DYNAMODB_ERROR_PROBABILITY %% DynamoDB error probability %% 0.0
if [ ! -v DYNAMODB_ERROR_PROBABILITY ]; then
	export DYNAMODB_ERROR_PROBABILITY=0.0
fi

#% 🔹 LAMBDA_EXECUTOR %% Lambda executor %% docker
export LAMBDA_EXECUTOR="docker"

#% 🔹 DATA_DIR %% Persistent data storage on Docker host %% /tmp/localstack/data
export DATA_DIR="/tmp/localstack/data"

#% 🔹 TMP_DIR %% Temp data storage on Docker host %% /tmp/localstack
export TMP_DIR="/tmp/localstack"

# Localstack hostnames
if [ ! -v TRAEFIK_ACME ]; then
	export LS_HOSTS=localstack.genv
fi

if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export LS_HOSTS+=",localstack.${i}"
	done
fi

#% 🔺 AWS_ACCESS_KEY_ID %% AWS API Access Key ID %% foobar
if [ ! -v AWS_ACCESS_KEY_ID ]; then
    export AWS_ACCESS_KEY_ID=foobar
fi

#% 🔺 AWS_SECRET_ACCESS_KEY %% AWS API Secret Access Key %% foobar
if [ ! -v AWS_SECRET_ACCESS_KEY ]; then
    export AWS_SECRET_ACCESS_KEY=foobar
fi

#% 🔺 AWS_REGION %% AWS API Region %% $DEFAULT_REGION
if [ ! -v AWS_REGION ]; then
    export AWS_REGION=${DEFAULT_REGION}
fi


localstack_up() {
	mkdir -p ${TMP_DIR}; chmod -R 777 ${TMP_DIR}
}