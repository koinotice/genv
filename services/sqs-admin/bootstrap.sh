#!/usr/bin/env bash

#% 🔺 AWS_ACCESS_KEY_ID %% AWS API Access Key ID %% foobar
if [ ! -v AWS_ACCESS_KEY_ID ]; then
    export AWS_ACCESS_KEY_ID=foobar
fi

#% 🔺 AWS_SECRET_ACCESS_KEY %% AWS API Secret Access Key %% foobar
if [ ! -v AWS_SECRET_ACCESS_KEY ]; then
    export AWS_SECRET_ACCESS_KEY=foobar
fi

#% 🔺 AWS_REGION %% AWS API Region %% us-east-1
if [ ! -v AWS_REGION ]; then
    export AWS_REGION=us-east-1
fi

#% 🔺 SQS_ENDPOINT %% SQS endpoint URL %% http://harpoon.dev:4576 (LocalStack)
if [ ! -v SQS_ENDPOINT ]; then
	export SQS_ENDPOINT=http://harpoon.dev:4576
fi

#% 🔺 SQS_ADMIN_PORT %% SQS Admin Port %% 8002
if [ ! -v SQS_ADMIN_PORT ]; then
	export SQS_ADMIN_PORT=8002
fi


# SQS Admin hostnames
if [ ! -v TRAEFIK_ACME ]; then
	export SQS_ADMIN_HOSTS=sqsadmin.harpoon.dev,sqs-admin.harpoon.dev
fi

if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export SQS_ADMIN_HOSTS+=",sqsadmin.${i},sqs-admin.${i}"
	done
fi