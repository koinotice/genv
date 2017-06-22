#!/usr/bin/env bash

set -euo pipefail

add() {
	FILE=${1}
	NAME=$(basename ${FILE})
	echo "Adding ${FILE}..."
	docker run --rm --volumes-from=harpoon_ssh-agent -v ${FILE}:/root/.ssh/${NAME} -it wheniwork/ssh-agent ssh-add /root/.ssh/${NAME}
}

add_all() {
	find ~/.ssh -type f -name 'id_*' -a ! -name '*.pub' | while read file; do
		(add "$file") < /dev/tty
	done
}


case "${command:-}" in
	ssh-agent:add) ## <keyfile> %% Add a key
		file=${args}
		if [ -z "${file}" ]
		then
			add_all
		else
			add ${file}
		fi
		;;

	ssh-agent:add:all) ## %% Add all your keys
		add_all ;;

	ssh-agent:add-if-none)
		${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} exec ssh-agent ssh-add -l || EXIT_CODE=$?

		if [[ ${EXIT_CODE:-} ]]; then
			echo "Adding all SSH keys..."
			add_all
		fi
		;;

	ssh-agent:list) ## %% List your keys
		${DOCKER_COMPOSE_CMD} ${DKR_COMPOSE_FILE} exec ssh-agent ssh-add -l ;;

	*)
		service_help ssh-agent;;
esac
