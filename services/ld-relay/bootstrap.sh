#!/usr/bin/env bash

if [ ! -v LD_RELAY_REDIS_HOST ]; then
	export REDIS_HOST=genv_redis
else
	export REDIS_HOST=${LD_RELAY_REDIS_HOST}
fi

if [ ! -v LD_RELAY_REDIS_PORT ]; then
	export REDIS_PORT=6379
else
	export REDIS_PORT=${LD_RELAY_REDIS_PORT}
fi

#% 🔺 LD_RELAY_PORT %% LaunchDarkly Relay Proxy HTTP port %% 8030
if [ ! -v LD_RELAY_PORT ]; then
	export LD_RELAY_PORT=8030
fi

# LaunchDarkly Relay Proxy hostnames
if [ ! -v TRAEFIK_ACME ]; then
	export LDRELAY_HOSTS=ld-relay.genv,ldrelay.genv
fi

if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export LDRELAY_HOSTS+=",ld-relay.${i},ldrelay.${i}"
	done
fi

ld-relay_pre_up() {
	if [ -v USE_REDIS ]; then
		serviceUpIfDown redis
	fi
}

ld-relay_post_down() {
	if [ -v USE_REDIS ]; then
		serviceDownIfUp redis
	fi
}

ld-relay_post_destroy() {
	if [ -v USE_REDIS ]; then
		serviceDestroyIfUp redis
	fi
}

ld-relay_post_clean() {
	if [ -v USE_REDIS ]; then
		serviceCleanIfUp redis
	fi
}