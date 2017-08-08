#!/usr/bin/env bash

if [ ! -v AWS_ACCESS_KEY_ID ]; then
    export AWS_ACCESS_KEY_ID=foobar
fi

if [ ! -v AWS_SECRET_ACCESS_KEY ]; then
    export AWS_SECRET_ACCESS_KEY=foobar
fi

if [ ! -v AWS_REGION ]; then
    export AWS_REGION=us-east-1
fi

if [ ! -v SQS_ENDPOINT ]; then
	export SQS_ENDPOINT=http://harpoon.dev:4576
fi

if [ ! -v SQS_ADMIN_PORT ]; then
	export SQS_ADMIN_PORT=8002
fi


# SQS Admin hostnames
if [ ! ${TRAEFIK_ACME:-} ]; then
	export SQS_ADMIN_HOSTS=sqsadmin.harpoon.dev,sqs-admin.harpoon.dev
fi

if [ ${CUSTOM_DOMAINS:-} ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export SQS_ADMIN_HOSTS+=",sqsadmin.${i},sqs-admin.${i}"
	done
fi