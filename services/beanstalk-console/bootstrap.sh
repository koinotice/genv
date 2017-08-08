#!/usr/bin/env bash

if [ ! ${TRAEFIK_ACME:-} ]; then
	export BEANSTALK_CONSOLE_HOSTS=beanstalk-console.harpoon.dev
fi

if [ ${CUSTOM_DOMAINS:-} ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export BEANSTALK_CONSOLE_HOSTS+=",beanstalk-console.${i}"
	done
fi

if [ ! ${BEANSTALKD_HOST:-} ]; then
	export BEANSTALKD_HOST=beanstalkd
fi

if [ ! ${BEANSTALKD_PORT:-} ]; then
	export BEANSTALKD_PORT=11300
fi
