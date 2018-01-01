#!/usr/bin/env bash

add() {
	local file=${1}
	local name=$(basename ${file})
	printInfo "Adding ${file}..."


	if [ ! -v CI ]; then
		# must use interactive TTY to support password entry
		local dkrRunFlags="-it"
	fi

	docker cp ${file} harpoon_ssh-agent:/root/.ssh/${name}
	docker exec ${dkrRunFlags:-} harpoon_ssh-agent ssh-add /root/.ssh/${name}
}

addAll() {
	for file in $(find ~/.ssh -type f -name 'id_*' -a ! -name '*.pub'); do
		add "$file"
	done
}


case "${command}" in
	ssh-agent:add) ## <keyfile> %% Add a key
		file=${args}
		if [ -z "${file}" ]; then
			addAll
		else
			add ${file}
		fi
		;;

	ssh-agent:add:all) ## %% Add all your keys
		addAll ;;

	ssh-agent:add-if-none)
		$(serviceDockerComposeExec ssh-agent) ssh-agent ssh-add -l || EXIT_CODE=$?

		if [ ${EXIT_CODE:-} ]; then
			printInfo "Adding all SSH keys..."
			addAll
		fi
		;;

	ssh-agent:list) ## %% List your keys
		$(serviceDockerComposeExec ssh-agent) ssh-agent ssh-add -l ;;

	*)
		serviceHelp ssh-agent
esac
