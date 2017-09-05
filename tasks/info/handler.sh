#!/usr/bin/env bash

case "${command}" in
	info:branch) ## %% Display the current VCS branch
		echo ${VCS_BRANCH} ;;

	info:tag) ## %% Display the interpolated tag name (used with the image:* tasks)
		echo ${TAG_NAME} ;;

	info:build-number) ## %% Display the current build number
		echo ${BUILD_NUMBER} ;;

	info:version) ## %% Display the project version
		echo ${PROJECT_VERSION} ;;

	info:rev) ## %% Display the current VCS revision/commit hash
		echo ${VCS_REVISION} ;;

	info:compose-project-name) ## %% Display the interpolated Docker Compose project name
		echo ${COMPOSE_PROJECT_NAME} ;;

	*)
		taskHelp
esac
