#!/usr/bin/env bash

if [ ! -v GENV_{{NAME}}_IMAGE_VERSION ]; then
	export GENV_{{NAME}}_IMAGE_VERSION=latest
fi

if [ ! -v GENV_{{NAME}}_IMAGE ]; then
	export GENV_{{NAME}}_IMAGE={{REPO}}:${GENV_{{NAME}}_IMAGE_VERSION}
fi

if [ ! -v GENV_{{NAME}}_CMD ]; then
	export GENV_{{NAME}}_CMD=""
fi

genv_{{NAME}}CLI() {
	printDebug "{{NAME}} args: $@"
	dockerRun -i ${GENV_{{NAME}}_IMAGE} ${GENV_{{NAME}}_CMD} $@
}