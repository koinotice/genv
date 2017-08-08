#!/usr/bin/env bash

if [ ! -v DOCKER_IMAGE ]; then
	export DOCKER_IMAGE=wheniwork/harpoon
fi

case "${command:-}" in
	docker) ## <arg>... %% 🐳  Execute a `docker` command in the Harpoon environment
		docker ${args} ;;

	docker:run) ## <arg>... %% 🐳  Docker `run` in the Harpoon environment
		docker_run ${args} ;;

	docker:run:dynamic) ## <arg>... %% 🐳  Docker `run` in the Harpoon environment with your dynamic env vars
		docker_run_with_dynamic_env ${args} ;;

	docker:compose) ## <arg>... %% 🐳  Run docker-compose with your project configuration
		docker_run ${DOCKER_IMAGE} "docker-compose ${args}" ;;

	docker:compose:dynamic) ## <arg>...	%% 🐳  Run docker-compose with your project configuration and dynamic env vars
		docker_run_with_dynamic_env ${DOCKER_IMAGE} "docker-compose ${args}" ;;

	docker:prune) ## %% 🐳  Remove dangling images and volumes
		docker image prune -f
		docker volume prune -f
		;;

	docker:chown) ## [dir] %% 🐳  Reset the owner of a directory to your current user [default: $PWD]
		chown_dir=${args:-$PWD}

		print_info "Chowning $chown_dir with uid: $USER_UID, gid: $USER_GID"

		docker_run alpine chown -R ${USER_UID}:${USER_GID} ${chown_dir}
		;;

	docker:help)
		module_help
esac