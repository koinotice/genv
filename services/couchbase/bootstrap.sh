#!/usr/bin/env bash

if [ ! -v COUCHBASE_VERSION ]; then
	export COUCHBASE_VERSION="latest"
fi

# Couchbase hostnames
export CB_HOST=couchbase.harpoon.dev
export CBPVR_HOSTS="couchbase-provisioner.harpoon.dev,cbpvr.harpoon.dev"

if [ -v CUSTOM_COUCHBASE_DOMAIN ]; then
	export CB_HOST="couchbase.${CUSTOM_COUCHBASE_DOMAIN}"
	export CBPVR_HOSTS+=",couchbase-provisioner.${CUSTOM_COUCHBASE_DOMAIN},cbpvr.${CUSTOM_COUCHBASE_DOMAIN}"
fi

export COUCHBASE_VOLUME_NAME=couchbase

couchbaseProvisionerRun() {
	cat ${SERVICES_ROOT}/couchbase/couchbase_default.yaml | sed -e "s/CB_HOST/${CB_HOST}/" | httpie -v -F --verify=no -a 12345:secret --pretty=all POST http://cbpvr.harpoon.dev:8080/clusters/ Content-Type:application/yaml
}

couchbase_post_up() {
	sleep 10
	couchbaseProvisionerRun
}

couchbase_pre_up() {
	local volumeCreated=$(docker volume ls | grep ${COUCHBASE_VOLUME_NAME}) || true

	if [[ "${volumeCreated}" == "" ]]; then
		printInfo "Creating docker volume named '${COUCHBASE_VOLUME_NAME}'..."
		docker volume create --name=${COUCHBASE_VOLUME_NAME}
	fi
}

couchbaseRemoveVolume() {
	local volumeCreated=$(docker volume ls | grep ${COUCHBASE_VOLUME_NAME}) || true

	if [[ "${volumeCreated}" != "" ]]; then
		printInfo "Removing docker volume named '${COUCHBASE_VOLUME_NAME}'..."
		docker volume rm ${COUCHBASE_VOLUME_NAME}
	fi
}

couchbase_post_destroy() {
	couchbaseRemoveVolume
}

couchbase_post_clean() {
	couchbaseRemoveVolume
}