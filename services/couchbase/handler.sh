#!/usr/bin/env bash

couchbaseCLI() {
	local cmd=${1:-}
	local opts=${2:-}

	if [ ${cmd} ]; then
		$(serviceDockerComposeExec couchbase) couchbase couchbase-cli ${cmd} -c localhost:8091 ${opts} -u Administrator -p abc123
	else
		$(serviceDockerComposeExec couchbase) couchbase couchbase-cli
	fi
}

case "${command}" in
	couchbase:provisioner:run) ## %% 🏁  Run the Couchbase Provisioner
		couchbaseProvisionerRun ;;

	couchbase:cbq) ## <arg>... %% 🛋  Couchbase N1QL query CLI
		$(serviceDockerComposeExec couchbase) couchbase cbq ${args} ;;

	couchbase:cli) ## <command> <options...> %% 🎮  Run a couchbase-cli command
		read -r -a argarray <<< "$args"
		couchbaseCLI ${argarray[0]:-} ${argarray[@]:1}
		;;

	couchbase:bucket-create) ## <name> [ramsize] %% 🍿  Create a Couchbase bucket
		# couchbase-cli bucket-create -c 192.168.0.1:8091 \
        # --bucket=test_bucket \
        # --bucket-type=couchbase \
        # --bucket-port=11222 \
        # --bucket-replica=1 \
        # --bucket-ramsize=200 \
        # --bucket-priority=low \
        # --wait \
        # --enable-flush=1 \
        # -u Administrator -p password

		read -r -a argarray <<< "$args"

		if [ ${argarray[1]:-} ]; then
			ramsize=${argarray[1]}
		else
			ramsize=128
		fi

		couchbaseCLI bucket-create "--bucket=${argarray[0]} --bucket-type=couchbase --bucket-ramsize=${ramsize} --enable-flush=1 --bucket-replica=0 --wait"
		;;

	couchbase:bucket-delete) ## <name> %% 🗑  Delete a bucket
		read -r -a argarray <<< "$args"
		couchbaseCLI bucket-delete "--bucket=${argarray[0]}"
		;;

	*)
		serviceHelp couchbase
esac

