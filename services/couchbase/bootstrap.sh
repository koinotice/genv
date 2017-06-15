#!/usr/bin/env bash

set -euo pipefail

if [ ! ${COUCHBASE_VERSION:-} ]; then
	export COUCHBASE_VERSION="latest"
fi

# Couchbase hostnames
export CB_HOST=couchbase.harpoon.dev
export CBPVR_HOSTS="couchbase-provisioner.harpoon.dev,cbpvr.harpoon.dev"

if [ ${CUSTOM_COUCHBASE_DOMAIN:-} ]; then
	export CB_HOST="couchbase.${CUSTOM_COUCHBASE_DOMAIN}"
	export CBPVR_HOSTS+=",couchbase-provisioner.${CUSTOM_COUCHBASE_DOMAIN},cbpvr.${CUSTOM_COUCHBASE_DOMAIN}"
fi

couchbase_provisioner_run() {
	cat ${SERVICES_ROOT}/couchbase/couchbase_default.yaml | sed -e "s/CB_HOST/${CB_HOST}/" | ${HTTPIE} -v -F --verify=no -a 12345:secret --pretty=all POST http://cbpvr.harpoon.dev:8080/clusters/ Content-Type:application/yaml
}

couchbase_post_up() {
	sleep 10
	couchbase_provisioner_run
}

couchbase_pre_up() {
	docker volume create --name=couchbase || true
}

couchbase_remove_volume() {
	docker volume rm couchbase || true
}

couchbase_post_destroy() {
	couchbase_remove_volume
}

couchbase_post_clean() {
	couchbase_remove_volume
}