#!/usr/bin/env bash

if [ ! -v TRAEFIK_ACME ]; then
	export BEANSTALK_CONSOLE_HOSTS=beanstalk-console.genv
fi

if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export BEANSTALK_CONSOLE_HOSTS+=",beanstalk-console.${i}"
	done
fi

#% 🔺 BEANSTALKD_HOST %% Beanstalkd container hostname %% beanstalkd
if [ ! -v BEANSTALKD_HOST ]; then
	export BEANSTALKD_HOST=beanstalkd
fi

#% 🔺 BEANSTALKD_PORT %% Beanstalkd container port %% 11300
if [ ! -v BEANSTALKD_PORT ]; then
	export BEANSTALKD_PORT=11300
fi
