#!/usr/bin/env bash

set -e

if [ ! ${COUCHBASE_VERSION} ]; then
	export COUCHBASE_VERSION="latest"
fi
