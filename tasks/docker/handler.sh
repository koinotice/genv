#!/usr/bin/env bash

case "${command}" in
	docker) ## <arg>... %% 🐳  Execute a `docker` command in the Genv environment
		docker ${args} ;;

	docker:run) ## <arg>... %% 🐳  Docker `run` in the Genv environment
		dockerRun ${args} ;;

	docker:run:dynamic) ## <arg>... %% 🐳  Docker `run` in the Genv environment with your dynamic env vars
		dockerRunWithDynamicEnv ${args} ;;

	docker:compose) ## <arg>... %% 🐳  Run docker-compose with your project configuration
		${GENV_DOCKER_COMPOSE_CMD} ${args} ;;

	docker:compose:dynamic) ## <arg>...	%% 🐳  Run docker-compose with your project configuration and dynamic env vars
		loadDynamicEnv
		${GENV_DOCKER_COMPOSE_CMD} ${args}
		;;

	docker:prune) ## %% 🐳  Remove dangling images and volumes
		printInfo "Removing dangling images and volumes..."
		docker image prune -f
		docker volume prune -f
		;;

	docker:nuke) ## %% 💥  Destroy all running containers and volumes by force
		docker ps -a | grep -v CONTAINER | awk '{print $1}' | xargs docker rm -f -v ;;

	docker:chown) ## [dir] %% 🐳  Reset the owner of a directory to your current user [default: $PWD]
		chown_dir=${args:-$PWD}

		printInfo "Chowning $chown_dir with uid: $USER_UID, gid: $USER_GID"

		dockerRun alpine chown -R ${USER_UID}:${USER_GID} ${chown_dir}
		;;

	docker:load) ## [dir] %% 🐳  Load Docker image (tar) files from a directory [default: $GENV_ROOT/images]
		images_dir=${args:-$GENV_IMAGES_ROOT}

		if [ ! -d ${images_dir} ]; then
			printWarn "Skipping image loading: '${images_dir}' is not a directory."
		else
			printInfo "Loading images from '${images_dir}'..."
			cwd=$PWD
			cd ${images_dir}

			for i in $(ls ${images_dir}); do
				docker load -i ${i} || true
			done

			cd ${cwd}
		fi
		;;

	docker:help)
		taskHelp ;;

	*)
		taskHelp
esac