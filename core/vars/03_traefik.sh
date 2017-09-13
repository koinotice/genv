#!/usr/bin/env bash

#% 🔺 TRAEFIK_DOCKER_CONSTRAINTS %% Traefik Docker backend constraints %% tag==harpoon
if [ ! -v TRAEFIK_DOCKER_CONSTRAINTS ]; then
	export TRAEFIK_DOCKER_CONSTRAINTS='tag==harpoon'
fi

#% 🔺 TRAEFIK_DOCKER_TAGS %% Traefik Docker tags %% harpoon
if [ ! -v TRAEFIK_DOCKER_TAGS ]; then
	export TRAEFIK_DOCKER_TAGS='harpoon'
fi

export TRAEFIK_COMMAND="
--docker.constraints='${TRAEFIK_DOCKER_CONSTRAINTS}'
"

#% 🔺 TRAEFIK_HTTP_PORT %% Traefik HTTP port published to Docker host %% 80
if [ ! -v TRAEFIK_HTTP_PORT ]; then
	export TRAEFIK_HTTP_PORT=80
fi

#% 🔺 TRAEFIK_HTTPS_PORT %% Traefik HTTPS port published to Docker host %% 443
if [ ! -v TRAEFIK_HTTPS_PORT ]; then
	export TRAEFIK_HTTPS_PORT=443
fi

export FRONTEND_ENTRYPOINTS=http


# ACME

#% 🔺 TRAEFIK_ACME_LOGGING %% Traefik Let's Encrypt Logging %% false
if [ ! -v TRAEFIK_ACME_LOGGING ]; then
	export TRAEFIK_ACME_LOGGING="false"
fi

#% 🔺 TRAEFIK_ACME_DNSPROVIDER %% Traefik Let's Encrypt DNS provider %% manual
if [ ! -v TRAEFIK_ACME_DNSPROVIDER ]; then
	export TRAEFIK_ACME_DNSPROVIDER="manual"
fi

#% 🔺 TRAEFIK_ACME_EMAIL %% Traefik Let's Encrypt e-mail address %% test@example.com
if [ ! -v TRAEFIK_ACME_EMAIL ]; then
	export TRAEFIK_ACME_EMAIL="test@example.com"
fi

#% 🔺 TRAEFIK_ACME_ONDEMAND %% Traefik Let's Encrypt generate certs on demand %% false
if [ ! -v TRAEFIK_ACME_ONDEMAND ]; then
	export TRAEFIK_ACME_ONDEMAND="false"
fi

#% 🔺 TRAEFIK_ACME_ONHOSTRULE %% Traefik Let's Encrypt generate certs on host rule %% false
if [ ! -v TRAEFIK_ACME_ONHOSTRULE ]; then
	export TRAEFIK_ACME_ONHOSTRULE="false"
fi

#% 🔺 TRAEFIK_ACME_STORAGE %% Traefik Let's Encrypt config file (mounted to container) %% /etc/traefik/acme/acme.json
if [ ! -v TRAEFIK_ACME_STORAGE ]; then
	export TRAEFIK_ACME_STORAGE="/etc/traefik/acme/acme.json"
fi

if [ -v TRAEFIK_ACME ]; then
	export TRAEFIK_COMMAND="
${TRAEFIK_COMMAND}
--acme
--acme.acmelogging=${TRAEFIK_ACME_LOGGING}
--acme.dnsprovider=${TRAEFIK_ACME_DNSPROVIDER}
--acme.email=${TRAEFIK_ACME_EMAIL}
--acme.entrypoint=https
--acme.ondemand=${TRAEFIK_ACME_ONDEMAND}
--acme.onhostrule=${TRAEFIK_ACME_ONHOSTRULE}
--acme.storage=${TRAEFIK_ACME_STORAGE}
--entryPoints='Name:https Address::443 TLS'
"
	if [ -v TRAEFIK_ACME_STAGING ]; then
		export TRAEFIK_COMMAND="
${TRAEFIK_COMMAND}
--acme.caserver='https://acme-staging.api.letsencrypt.org/directory'
	"
	fi

	export FRONTEND_ENTRYPOINTS="http,https"
fi


if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		if [[ -f "${HARPOON_ROOT}/core/traefik/certs/${i}.crt" && -f "${HARPOON_ROOT}/core/traefik/certs/${i}.key" ]]; then
			CERTS+="/etc/traefik/certs/${i}.crt,/etc/traefik/certs/${i}.key;"
		fi
	done

	if [ -v CERTS ]; then
		CERTS=$(echo ${CERTS} | sed 's/;$//')

		export TRAEFIK_COMMAND+="
--entryPoints='Name:https Address::443 TLS:${CERTS}'
"
		export FRONTEND_ENTRYPOINTS="http,https"
	fi

fi
