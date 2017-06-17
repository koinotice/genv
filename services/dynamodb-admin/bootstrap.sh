#!/usr/bin/env bash

set -euo pipefail

if [ ! ${AWS_ACCESS_KEY_ID:-} ]; then
    export AWS_ACCESS_KEY_ID=foobar
fi

if [ ! ${AWS_SECRET_ACCESS_KEY:-} ]; then
    export AWS_SECRET_ACCESS_KEY=foobar
fi

if [ ! ${AWS_REGION:-} ]; then
    export AWS_REGION=us-east-1
fi

if [ ! ${DYNAMO_ENDPOINT:-} ]; then
	export DYNAMO_ENDPOINT=http://harpoon.dev:4569
fi

# DynamoDB Admin hostnames
export DDB_ADMIN_HOSTS=ddbadmin.harpoon.dev,dynamodb-admin.harpoon.dev

if [ ${CUSTOM_DOMAINS:-} ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export DDB_ADMIN_HOSTS+=",ddbadmin.${i},dynamodb-admin.${i}"
	done
fi