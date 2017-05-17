#!/usr/bin/env bash

set -euo pipefail

case "${command:-}" in
	ssh-agent:add)
		file=${args}
		echo "Adding ${file}..."
		docker run --rm --volumes-from=ssh-agent -v ${file}:/root/.ssh/id_rsa -it sshagent_ssh-agent ssh-add /root/.ssh/id_rsa
		;;
	ssh-agent:list)
		docker-compose ${DKR_COMPOSE_FILE} exec ssh-agent ssh-add -l
		;;
	*)
		service_help ssh-agent;;
esac
