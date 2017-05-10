#!/usr/bin/env bash

set -e

if [ ! ${TRAEFIK_HTTP_PORT} ]; then
	export TRAEFIK_HTTP_PORT=80
fi

if [ ! ${TRAEFIK_HTTPS_PORT} ]; then
	export TRAEFIK_HTTPS_PORT=443
fi


# ACME

if [ ! ${TRAEFIK_ACME_LOGGING} ]; then
	export TRAEFIK_ACME_LOGGING="false"
fi

if [ ! ${TRAEFIK_ACME_DNSPROVIDER} ]; then
	export TRAEFIK_ACME_DNSPROVIDER="manual"
fi

if [ ! ${TRAEFIK_ACME_EMAIL} ]; then
	export TRAEFIK_ACME_EMAIL="test@example.com"
fi

if [ ! ${TRAEFIK_ACME_ONDEMAND} ]; then
	export TRAEFIK_ACME_ONDEMAND="false"
fi

if [ ! ${TRAEFIK_ACME_ONHOSTRULE} ]; then
	export TRAEFIK_ACME_ONHOSTRULE="false"
fi

if [ ! ${TRAEFIK_ACME_STORAGE} ]; then
	export TRAEFIK_ACME_STORAGE="/etc/traefik/acme/acme.json"
fi

if [ ${TRAEFIK_ACME} ]; then
	export TRAEFIK_COMMAND="
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
	if [ ${TRAEFIK_ACME_STAGING} ]; then
		export TRAEFIK_COMMAND="
${TRAEFIK_COMMAND}
--acme.caserver='https://acme-staging.api.letsencrypt.org/directory'
	"
	fi
fi

if [[ ${TRAEFIK_TLS_CERTFILE} && ${TRAEFIK_TLS_KEYFILE} ]]; then
	export TRAEFIK_COMMAND="
--entryPoints='Name:https Address::443 TLS:/etc/traefik/certs/${TRAEFIK_TLS_CERTFILE},/etc/traefik/certs/${TRAEFIK_TLS_KEYFILE}'
"
fi

if [ ${TRAEFIK_HELP} ]; then
	export TRAEFIK_COMMAND="-h"
fi