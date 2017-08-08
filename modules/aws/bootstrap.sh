#!/usr/bin/env

if [ ! ${AWS_IMAGE_VERSION:-} ]; then
	export AWS_IMAGE_VERSION=latest
fi

if [ ! ${AWS_IMAGE:-} ]; then
	export AWS_IMAGE=cgswong/aws:${AWS_IMAGE_VERSION}
fi

if [ ! ${AWS_CMD:-} ]; then
	export AWS_CMD=""
fi

aws_cli() {
	print_debug "aws args: $@"
	docker_run -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION -v ${HOME}/.aws/:/root/.aws ${AWS_IMAGE} ${AWS_CMD} $@
}