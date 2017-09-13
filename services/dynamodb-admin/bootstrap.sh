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

#% 🔺 DYNAMO_ENDPOINT %% DynamoDB endpoint URL %% http://harpoon.dev:4569 (LocalStack)
if [ ! -v DYNAMO_ENDPOINT ]; then
	export DYNAMO_ENDPOINT=http://harpoon.dev:4569
fi

# DynamoDB Admin hostnames
if [ ! -v TRAEFIK_ACME ]; then
	export DDB_ADMIN_HOSTS=ddbadmin.harpoon.dev,dynamodb-admin.harpoon.dev
fi

if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export DDB_ADMIN_HOSTS+=",ddbadmin.${i},dynamodb-admin.${i}"
	done
fi