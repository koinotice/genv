#!/usr/bin/env

#% 🔺 AWS_IMAGE_VERSION %% AWS CLI Docker image version %% latest
if [ ! -v AWS_IMAGE_VERSION ]; then
	export AWS_IMAGE_VERSION=latest
fi

#% 🔺 AWS_IMAGE %% AWS CLI Docker image %% cgswong/aws:${AWS_IMAGE_VERSION}
if [ ! -v AWS_IMAGE ]; then
	export AWS_IMAGE=cgswong/aws:${AWS_IMAGE_VERSION}
fi

#% 🔺 AWS_CMD %% Override command for AWS CLI Docker container %%
if [ ! -v AWS_CMD ]; then
	export AWS_CMD=""
fi

aws_cli() {
	printDebug "aws args: $@"
	dockerRun -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION -v ${HOME}/.aws/:/root/.aws ${AWS_IMAGE} ${AWS_CMD} $@
}