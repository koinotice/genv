#!/usr/bin/env bash

#% 🔺 COUCHBASE_VERSION %% Couchbase Docker image version %% latest
if [ ! -v COUCHBASE_VERSION ]; then
	export COUCHBASE_VERSION="latest"
fi

# Couchbase hostnames
export CB_HOST=couchbase.int.harpoon
export CBPVR_HOSTS="couchbase-provisioner.harpoon,cbpvr.harpoon,couchbase-provisioner.harpoon.dev,cbpvr.harpoon.dev"

#% 🔺 CUSTOM_COUCHBASE_DOMAIN %% Custom domain name for Couchbase containers
if [ -v CUSTOM_COUCHBASE_DOMAIN ]; then
	export CB_HOST="couchbase.${CUSTOM_COUCHBASE_DOMAIN}"
	export CBPVR_HOSTS+=",couchbase-provisioner.${CUSTOM_COUCHBASE_DOMAIN},cbpvr.${CUSTOM_COUCHBASE_DOMAIN}"
fi

#% 🔹 COUCHBASE_VOLUME_NAME %% Couchbase Docker volume name %% couchbase
export COUCHBASE_VOLUME_NAME=couchbase

couchbaseProvisionerRun() {
	cat ${HARPOON_SERVICES_ROOT}/couchbase/couchbase_default.yaml | sed -e "s/CB_HOST/${CB_HOST}/" | httpie -v -F --verify=no -a 12345:secret --pretty=all POST http://cbpvr.int.harpoon:8080/clusters/ Content-Type:application/yaml
}

couchbase_pre_up() {
	local volumeCreated=$(docker volume ls | grep ${COUCHBASE_VOLUME_NAME}) || true

	if [[ "${volumeCreated}" == "" ]]; then
		printInfo "Creating docker volume named '${COUCHBASE_VOLUME_NAME}'..."
		docker volume create --name=${COUCHBASE_VOLUME_NAME}
	fi
}

couchbase_post_up() {
	sleep 10
	couchbaseProvisionerRun
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