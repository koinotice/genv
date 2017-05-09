#!/usr/bin/env bash

set -e

if [ ! ${AWS_ACCESS_KEY_ID} ]; then
	export AWS_ACCESS_KEY_ID=""
fi

if [ ! ${AWS_SECRET_ACCESS_KEY} ]; then
	export AWS_SECRET_ACCESS_KEY=""
fi

if [ ! ${AWS_REGION} ]; then
	export AWS_REGION="us-east-1"
fi