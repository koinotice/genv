#!/usr/bin/env bash

set -e

if [ ! ${COUCHBASE_VERSION} ]; then
	export COUCHBASE_VERSION="latest"
fi

couchbase_provisioner_run() {
	${HTTPIE} -v -F --verify=no -a 12345:secret --pretty=all POST http://cbpvr.harpoon.dev:8080/clusters Content-Type:application/yaml < ${SERVICES_ROOT}/couchbase/couchbase_default.yaml
}

couchbase_up() {
	sleep 10
	couchbase_provisioner_run
}