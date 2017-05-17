#!/usr/bin/env bash

set -euo pipefail

case "${command:-}" in
	couchbase:cbq) ## <arg>... %% Couchbase N1QL query CLI
		docker-compose ${SERVICE_COMPOSE_FILE} exec couchbase cbq ${args} ;;
	couchbase:provisioner:run) ## %% Run the Couchbase Provisioner
		couchbase_provisioner_run ;;
esac

