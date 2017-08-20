#!/usr/bin/env bash

case "${command:-}" in
	info:branch) ## %% Display the current VCS branch
		echo ${VCS_BRANCH} ;;

	info:version) ## %% Display the project version
		echo ${PROJECT_VERSION} ;;

	info:rev) ## %% Display the current VCS revision/commit hash
		echo ${VCS_REVISION} ;;

	info:compose-project-name) ## %% Display the interpolated Docker Compose project name
		echo ${COMPOSE_PROJECT_NAME} ;;

	*)
		task_help
esac
