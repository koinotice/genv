#!/usr/bin/env bash

set -euo pipefail

case "${command:-}" in
	couchbase:cbq) ## <arg>... %% Couchbase N1QL query CLI
		docker-compose ${DKR_COMPOSE_FILE} exec couchbase cbq ${args} ;;
	couchbase:provisioner:run) ## %% Run the Couchbase Provisioner
		couchbase_provisioner_run ;;
	*)
		service_help couchbase;;
esac

