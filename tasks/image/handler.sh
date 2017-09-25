#!/usr/bin/env bash

# set repository and build image name (repo+tag)
#% 🔺 REPOSITORY %% Docker image repository %% $CI_REGISTRY_IMAGE | ${REGISTRY_HOST}/${REPO_ROOT}
if [ ! -v REPOSITORY ]; then
	if [ -v CI_REGISTRY_IMAGE ]; then
		export REPOSITORY=${CI_REGISTRY_IMAGE}
	else
		export REPOSITORY=${REGISTRY_HOST}/${REPO_ROOT}
	fi
fi

printDebug "REPOSITORY: $REPOSITORY"

#% 🔺 BUILD_IMAGE %% Docker repoistory:tag to build %% ${REPOSITORY}:${TAG_NAME}
if [ ! -v BUILD_IMAGE ]; then
	export BUILD_IMAGE=${REPOSITORY}:${TAG_NAME}
fi

printDebug "BUILD_IMAGE (default): $BUILD_IMAGE"

#% 🔺 BUILD_DOCKERFILE %% Dockerfile to build %% Dockerfile
if [ ! -v BUILD_DOCKERFILE ]; then
	export BUILD_DOCKERFILE=Dockerfile
fi

printDebug "BUILD_DOCKERFILE: $BUILD_DOCKERFILE"

if [ -f "${BUILD_DOCKERFILE}" ]; then
	BUILD_FROM="$(grep FROM "${BUILD_DOCKERFILE}" | sed 's/FROM //g' | tr '\n' ' ')"
	IFS=' ' read -a FROM_ARRAY <<< "$BUILD_FROM"
fi

printDebug "BUILD_FROM: $BUILD_FROM"

#% 🔺 CONTAINER_OS %% OS referenced in build FROM statement %% alpine
if [ ! -v CONTAINER_OS ]; then
	if [ ${#FROM_ARRAY[@]} -gt 1 ]; then
		export CONTAINER_OS="$(echo "${FROM_ARRAY[-1]}" | grep -oe alpine -e xenial -e trusty || echo alpine)"
	else
		export CONTAINER_OS="$(echo "${BUILD_FROM:-}" | grep -oe alpine -e xenial -e trusty || echo alpine)"
	fi
fi

printDebug "CONTAINER_OS: $CONTAINER_OS"

## Detect whether we can / want to run tests on the container

#% 🔺 TESTS_ENABLED %% Run tests on built image %% true
if [ ! -v TESTS_ENABLED ]; then
	export TESTS_ENABLED=true
fi

#% 🔺 HAS_TESTS %% Image build has custom tests %% no (if no Gossfile exists)
if [[ -f 'Gossfile' && ! "${HAS_TESTS:-}" ]]; then
	export HAS_TESTS="$(grep -q Gossfile "${BUILD_DOCKERFILE}" && echo yes || echo no)"
fi

printDebug "HAS_TESTS: ${HAS_TESTS:-}"

#% 🔺 TEST_TYPE %% Image test type %% cli (if no HEALTHCHECKs)
if [[ -f "${BUILD_DOCKERFILE}" && ! -v TEST_TYPE ]]; then
	export TEST_TYPE="$(grep -q HEALTHCHECK "${BUILD_DOCKERFILE}" && echo service || echo cli)"
fi

printDebug "TEST_TYPE: $TEST_TYPE"

#% 🔺 TEST_RUN_TIME %% Wait time before tests run (in seconds) %% 5
if [ ! -v TEST_RUN_TIME ]; then
	export TEST_RUN_TIME=5
fi

printDebug "TEST_RUN_TIME: $TEST_RUN_TIME"


## Validate a service (daemon) container using its healthcheck

imageTestServiceRun() {
	rm -f .status
	docker run ${TEST_RUN_ARGS:-} --name "${PROJECT}" --detach --health-interval 1s "${PROJECT}"
}

imageTestServiceInspect() {
	sleep ${TEST_RUN_TIME}
	docker inspect --format '{{ range .State.Health.Log }}{{ println "======\nStart:" .Start }}{{ .Output }}{{end}}' "${PROJECT}"
	STATUS="$( docker inspect --format '{{.State.Health.Status}}' "${PROJECT}" )"
	[[ "${STATUS}" = 'healthy' ]]
}

imageTestServiceRemove() {
	docker rm -f "${PROJECT}"
}

imageTestService() {
	imageTestServiceRun
	imageTestServiceInspect
	local status=$?
	# clean up, then forward inspect's exit code
	imageTestServiceRemove
	return ${status}
}

## Validate a command-line wrapper container by running validation directly

imageTestCLI() {
	docker run ${TEST_RUN_ARGS:-} --rm --entrypoint /usr/local/bin/goss "${PROJECT}" -g /goss/goss.yaml validate --format documentation || { printPanic "Failed to run test container!"; }
}

## build and test wrappers

imageClean() {
	docker rm -f "${PROJECT}" || true
	docker rmi -f $(docker images | grep -m 1 ${PROJECT} | awk '{print $3}') || printInfo 'no images to delete'
}

imageSmokeTest() {
	[[ "${SMOKE_COMMAND:-}" ]] || return 0
	[[ "${SMOKE_ENTRYPOINT:-}" ]] && SMOKE_ENTRYPOINT="--entrypoint '${SMOKE_ENTRYPOINT}'"
	docker run --rm ${SMOKE_ENTRYPOINT:-} "${PROJECT}" bash -c "${SMOKE_COMMAND:-}" || { printPanic "Failed to run test container!"; }
}

imageBuild() {
	for img in ${FROM_ARRAY}; do
		if [ "${img}" = "scratch" ]; then
		  	printInfo "Found 'FROM scratch'. Skipping pull..."
		else
		  	docker pull "${img}" || { printPanic "Failed to pull ${img}!"; }
		fi
	done

	docker build --squash -f ${BUILD_DOCKERFILE} -t ${PROJECT} . || { printPanic "Failed to build ${PROJECT}!"; }
	docker history ${PROJECT}

	if [[ ${TESTS_ENABLED} == true ]]; then
		imageSmokeTest
	fi
}

imageCleanBuildTest() {
	imageClean
	imageBuild

	if [[ ${TESTS_ENABLED} == true ]]; then
		if [ "${HAS_TESTS:-}" = "yes" ]; then
		 if [ "${TEST_TYPE}" = "service" ]; then
		   imageTestService || { printPanic "Container failed service tests!"; }
		 else
		   imageTestCLI || { printPanic "Container failed CLI tests!"; }
		 fi
		fi
	fi
}

## Single tag and upload

imageTag() {
	docker tag $(docker images | grep "^${PROJECT} " | awk '{print $3;}') ${BUILD_IMAGE}
	docker tag $(docker images | grep "^${PROJECT} " | awk '{print $3;}') ${REPOSITORY}
}

# $1 <image name>
imageTagPushClean() {
	printInfo "Uploading ${PROJECT} $1..."
	docker tag "${PROJECT}" "$1"
	docker push "$1" || { printPanic "Failed to push $1!"; }
	docker rmi -f "$1"
}

# $1 <image name>
imageUpload() {
	imageBuild

	if [[ "${1:-}" != "" ]]; then
		export REPOSITORY=${REPOSITORY}/${1}
		export BUILD_IMAGE=${REPOSITORY}:${TAG_NAME}
	fi

	printInfo "REPOSITORY=${REPOSITORY}"
	printInfo "BUILD_IMAGE=${BUILD_IMAGE}"

	if [[ "${VCS_BRANCH}" == "master" || -v TRAVIS_TAG ]]; then
		imageTagPushClean "${REPOSITORY}:master"
		imageTagPushClean "${REPOSITORY}:latest"

		if [[ "${TAG_NAME}" != "" ]]; then
			imageTagPushClean ${BUILD_IMAGE}
		fi
	else
		imageTagPushClean ${BUILD_IMAGE}
	fi

	imageClean
}

## Multi tag and upload
## Reflect the wrapped software's version and use it to tag the image
## Upload the image to the registry

imageVersion() {
	# emit a version like 12.34.5678 as well as 12.34.56-patch7.8.9
	docker run --rm ${PROJECT} bash -c "${VERSION_COMMAND}" 2>&1 | grep -o '[0-9][0-9]*\.[0-9][0-9]*[a-zA-Z0-9._-]*' | head -1
}

imageBuildVersionUpload() {
	imageCleanBuildTest || { printPanic "Failed to build ${PROJECT}!"; }

	local version="$(imageVersion)" || true

	if [ ! ${version} ]; then
		printPanic "Unable to determine version!"
	fi

	local major="$(echo ${version} | cut -f1 -d.)"
	local minor="$(echo ${version} | cut -f2 -d.)"
	local patch="$(echo ${version} | cut -f3 -d.)"

	# registry.example.com/your/project:7.0.14-alpine-1.2.3
	imageTagPushClean "${REPOSITORY}:${version}-${CONTAINER_OS}-${TAG_NAME}${SUFFIX:-}"

	# registry.example.com/your/project:7.0.14-alpine
	imageTagPushClean "${REPOSITORY}:${version}-${CONTAINER_OS}${SUFFIX:-}"

	for n in $(echo "${VERSION_TAGS:-}" | tr ',' ' '); do
	 case ${n} in
	   minor)
	     # registry.example.com/your/project:7.0-alpine
	     imageTagPushClean "${REPOSITORY}:${major}.${minor}-${CONTAINER_OS}${SUFFIX:-}";;
	   major)
	     # registry.example.com/your/project:7-alpine
	     imageTagPushClean "${REPOSITORY}:${major}-${CONTAINER_OS}${SUFFIX:-}";;
	   os)
	     # registry.example.com/your/project:alpine
	     imageTagPushClean "${REPOSITORY}:${CONTAINER_OS}${SUFFIX:-}";;
	   latest)
	     # registry.example.com/your/project
	     imageTagPushClean "${REPOSITORY}";;
	 esac
	done
}

case "${command}" in
	image:name) ## %% Display the Docker build image name
		echo ${BUILD_IMAGE} ;;

	image:clean-build-test) ## %% 🏗  Build and test the Docker image for your project
		imageCleanBuildTest ;;

	image:build) ## %% 🏗  Build the Docker image for your project
		imageBuild ;;

	image:build-date) ## %% Display a build-friendly timestamp for "now"
		echo ${NOW} ;;

	image:smoke-test) ## %% 🏗  Verify the Docker image can run
		imageSmokeTest ;;

	image:test-service) ## %% 🏗  Test a service (daemon) container
		imageTestService ;;

	image:test-service-run) ## %% 🏗  Start a service (daemon) container for testing
		imageTestServiceRun ;;

	image:test-service-inspect) ## %% 🏗  Inspect a service (daemon) container for testing
		imageTestServiceInspect ;;

	image:test-service-remove) ## %% 🏗  Remove the service (daemon) container for testing
		imageTestServiceRemove ;;

	image:test-cli) ## %% 🏗  Test a command-line container
		imageTestService ;;

	image:clean) ## %% 🗑  Remove all Docker images related to your project
		imageClean ;;

	image:tag) ## %% 🏷  Tag the Docker image for your project
		imageTag ;;

	image:upload) ## [<image name>] %% ⬆️  Upload your project's Docker image to your registry
		imageUpload ${args} ;;

	image:version) ## %% ⬆️  Reflect the wrapped software's version
		imageVersion ;;

	image:build-version-upload) ## %% ⬆️  Build and Upload multiple tagged Docker images to your registry
		imageBuildVersionUpload ;;

	*)
		taskHelp
esac