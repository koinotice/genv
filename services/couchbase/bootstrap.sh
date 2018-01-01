#!/usr/bin/env bash

#% 🔺 COUCHBASE_VERSION %% Couchbase Docker image version %% latest
if [ ! -v COUCHBASE_VERSION ]; then
	export COUCHBASE_VERSION="latest"
fi

# Couchbase hostnames
export CB_HOSTS="couchbase.harpoon"
export CBPVR_HOSTS="couchbase-provisioner.harpoon,cbpvr.harpoon"

if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export CB_HOSTS+=",couchbase.${i}"
		export CBPVR_HOSTS+=",couchbase-provisioner.${i},cbpvr.${i}"
	done
fi

#% 🔹 COUCHBASE_VOLUME_NAME %% Couchbase Docker volume name %% couchbase
export COUCHBASE_VOLUME_NAME=couchbase

couchbaseProvisionerRun() {
	cat ${HARPOON_SERVICES_ROOT}/couchbase/couchbase_default.yaml | httpie -v -F --verify=no -a 12345:secret --pretty=all POST http://cbpvr.${HARPOON_INT_DOMAIN}:8080/clusters/ Content-Type:application/yaml
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