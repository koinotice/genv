#!/usr/bin/env bash

add() {
	FILE=${1}
	NAME=$(basename ${FILE})
	echo "Adding ${FILE}..."
	docker run --rm --volumes-from=harpoon_ssh-agent -v ${FILE}:/root/.ssh/${NAME} wheniwork/ssh-agent ssh-add /root/.ssh/${NAME}
}

add_all() {
	for file in $(find ~/.ssh -type f -name 'id_*' -a ! -name '*.pub'); do
		add "$file"
	done
}


case "${command:-}" in
	ssh-agent:add) ## <keyfile> %% Add a key
		file=${args}
		if [ -z "${file}" ]; then
			add_all
		else
			add ${file}
		fi
		;;

	ssh-agent:add:all) ## %% Add all your keys
		add_all ;;

	ssh-agent:add-if-none)
		${DOCKER_COMPOSE_EXEC} ssh-agent ssh-add -l || EXIT_CODE=$?

		if [ ${EXIT_CODE:-} ]; then
			echo "Adding all SSH keys..."
			add_all
		fi
		;;

	ssh-agent:list) ## %% List your keys
		${DOCKER_COMPOSE_EXEC} ssh-agent ssh-add -l ;;

	*)
		service_help ssh-agent
esac
