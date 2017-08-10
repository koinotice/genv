#!/usr/bin/env bash

# set repository and build image name (repo+tag)
if [ ! -v REPOSITORY ]; then
	if [ -v CI_REGISTRY_IMAGE ]; then
		export REPOSITORY=${CI_REGISTRY_IMAGE}
	else
		export REPOSITORY=${REGISTRY_HOST}/${REPO_ROOT}
	fi
fi

print_debug "REPOSITORY: $REPOSITORY"

if [ ! -v BUILD_IMAGE ]; then
	export BUILD_IMAGE=${REPOSITORY}:${TAG_NAME}
fi

print_debug "BUILD_IMAGE (default): $BUILD_IMAGE"

if [ ! -v BUILD_DOCKERFILE ]; then
	export BUILD_DOCKERFILE=Dockerfile
fi

print_debug "BUILD_DOCKERFILE: $BUILD_DOCKERFILE"

if [ -f "${BUILD_DOCKERFILE}" ]; then
	BUILD_FROM="$(grep FROM "${BUILD_DOCKERFILE}" | sed 's/FROM //g')"
fi

print_debug "BUILD_FROM: $BUILD_FROM"

if [ ! -v CONTAINER_OS ]; then
	export CONTAINER_OS="$(echo "${BUILD_FROM:-}" | grep -oe alpine -e xenial -e trusty || echo alpine)"
fi

print_debug "CONTAINER_OS: $CONTAINER_OS"

## Detect whether we can / want to run tests on the container

if [ ! -v TESTS_ENABLED ]; then
	export TESTS_ENABLED=true
fi

if [[ -f 'Gossfile' && ! "${HAS_TESTS:-}" ]]; then
	export HAS_TESTS="$(grep -q Gossfile "${BUILD_DOCKERFILE}" && echo yes || echo no)"
fi

print_debug "HAS_TESTS: ${HAS_TESTS:-}"

if [[ -f "${BUILD_DOCKERFILE}" && ! -v TEST_TYPE ]]; then
	export TEST_TYPE="$(grep -q HEALTHCHECK "${BUILD_DOCKERFILE}" && echo service || echo cli)"
fi

print_debug "TEST_TYPE: $TEST_TYPE"

if [ ! -v TEST_RUN_TIME ]; then
	export TEST_RUN_TIME=5
fi

print_debug "TEST_RUN_TIME: $TEST_RUN_TIME"


## Validate a service (daemon) container using its healthcheck

image_test_service_run() {
	rm -f .status
	docker run ${TEST_RUN_ARGS:-} --name "${PROJECT}" --detach --health-interval 1s "${PROJECT}"
}

image_test_service_inspect() {
	sleep ${TEST_RUN_TIME}
	docker inspect --format '{{ range .State.Health.Log }}{{ println "======\nStart:" .Start }}{{ .Output }}{{end}}' "${PROJECT}"
	STATUS="$( docker inspect --format '{{.State.Health.Status}}' "${PROJECT}" )"
	[[ "${STATUS}" = 'healthy' ]]
}

image_test_service_remove() {
	docker rm -f "${PROJECT}"
}

image_test_service() {
	image_test_service_run
	image_test_service_inspect
	status=$?
	# clean up, then forward inspect's exit code
	image_test_service_remove
	return $status
}

## Validate a command-line wrapper container by running validation directly

image_test_cli() {
	docker run ${TEST_RUN_ARGS:-} --rm --entrypoint /usr/local/bin/goss "${PROJECT}" -g /goss/goss.yaml validate --format documentation || { print_panic "Failed to run test container!"; }
}

## build and test wrappers

image_clean() {
	docker rm -f "${PROJECT}" || true
	docker rmi -f $(docker images | grep -m 1 ${PROJECT} | awk '{print $3}') || print_info 'no images to delete'
}

image_smoke_test() {
	[[ "${SMOKE_COMMAND:-}" ]] || return 0
	[[ "${SMOKE_ENTRYPOINT:-}" ]] && SMOKE_ENTRYPOINT="--entrypoint '${SMOKE_ENTRYPOINT}'"
	docker run --rm ${SMOKE_ENTRYPOINT:-} "${PROJECT}" bash -c "${SMOKE_COMMAND:-}" || { print_panic "Failed to run test container!"; }
}

image_build() {
	if [ "${BUILD_FROM}" = "scratch" ]; then
	  print_info "Found 'FROM scratch'. Skipping pull..."
	else
	  docker pull "${BUILD_FROM}" || { print_panic "Failed to pull ${BUILD_FROM}!"; }
	fi

	docker build --squash -f ${BUILD_DOCKERFILE} -t ${PROJECT} . || { print_panic "Failed to build ${PROJECT}!"; }
	docker history ${PROJECT}

	if [[ ${TESTS_ENABLED} == true ]]; then
		image_smoke_test
	fi
}

image_clean_build_test() {
	image_clean
	image_build

	if [[ ${TESTS_ENABLED} == true ]]; then
		if [ "${HAS_TESTS:-}" = "yes" ]; then
		 if [ "${TEST_TYPE}" = "service" ]; then
		   image_test_service || { print_panic "Container failed tests!"; }
		 else
		   image_test_cli || { print_panic "Container failed tests!"; }
		 fi
		fi
	fi
}

## Single tag and upload

image_tag() {
	docker tag $(docker images | grep "^${PROJECT} " | awk '{print $3;}') ${BUILD_IMAGE}
	docker tag $(docker images | grep "^${PROJECT} " | awk '{print $3;}') ${REPOSITORY}
}

# $1 <image name>
image_tag_push_clean() {
	print_info "Uploading ${PROJECT} $1..."
	docker tag "${PROJECT}" "$1"
	docker push "$1" || { print_panic "Failed to push $1!"; }
	docker rmi -f "$1"
}

# $1 <image name>
image_upload() {
	image_build

	print_info "REPOSITORY=${REPOSITORY}"

	if [[ "${1:-}" != "" ]]; then
		export BUILD_IMAGE=${REPOSITORY}/${1}:${TAG_NAME}
	fi

	print_info "BUILD_IMAGE=${BUILD_IMAGE}"

	if [[ "${VCS_BRANCH}" == "master" ]]; then
		image_tag_push_clean "${REPOSITORY}:master"
		image_tag_push_clean "${REPOSITORY}:latest"
	else
		image_tag_push_clean ${BUILD_IMAGE}
	fi

	image_clean
}

## Multi tag and upload
## Reflect the wrapped software's version and use it to tag the image
## Upload the image to the registry

image_version() {
	# emit a version like 12.34.5678 as well as 12.34.56-patch7.8.9
	docker run --rm ${PROJECT} bash -c "${VERSION_COMMAND}" 2>&1 | grep -o '[0-9][0-9]*\.[0-9][0-9]*[a-zA-Z0-9._-]*' | head -1
}

image_build_version_upload() {
	image_clean_build_test || { print_panic "Failed to build ${PROJECT}!"; }

	VERSION="$(image_version)" || true

	if [ ! ${VERSION} ]; then
		print_panic "Unable to determine version!"
	fi

	MAJOR="$(echo ${VERSION} | cut -f1 -d.)"
	MINOR="$(echo ${VERSION} | cut -f2 -d.)"
	PATCH="$(echo ${VERSION} | cut -f3 -d.)"

	# registry.example.com/your/project:7.0.14-alpine-1.2.3
	image_tag_push_clean "${REPOSITORY}:${VERSION}-${CONTAINER_OS}-${TAG_NAME}${SUFFIX:-}"

	# registry.example.com/your/project:7.0.14-alpine
	image_tag_push_clean "${REPOSITORY}:${VERSION}-${CONTAINER_OS}${SUFFIX:-}"

	for n in $(echo "${VERSION_TAGS:-}" | tr ',' ' '); do
	 case ${n} in
	   minor)
	     # registry.example.com/your/project:7.0-alpine
	     image_tag_push_clean "${REPOSITORY}:${MAJOR}.${MINOR}-${CONTAINER_OS}${SUFFIX:-}";;
	   major)
	     # registry.example.com/your/project:7-alpine
	     image_tag_push_clean "${REPOSITORY}:${MAJOR}-${CONTAINER_OS}${SUFFIX:-}";;
	   os)
	     # registry.example.com/your/project:alpine
	     image_tag_push_clean "${REPOSITORY}:${CONTAINER_OS}${SUFFIX:-}";;
	   latest)
	     # registry.example.com/your/project
	     image_tag_push_clean "${REPOSITORY}";;
	 esac
	done
}

case "${command:-}" in
	image:name) ## %% Display the Docker build image name
		echo ${BUILD_IMAGE} ;;

	image:clean-build-test) ## %% 🏗  Build and test the Docker image for your project
		image_clean_build_test ;;

	image:build) ## %% 🏗  Build the Docker image for your project
		image_build ;;

	image:build-date) ## %% Display a build-friendly timestamp for "now"
		echo ${NOW} ;;

	image:smoke-test) ## %% 🏗  Verify the Docker image can run
		image_smoke_test ;;

	image:test-service) ## %% 🏗  Test a service (daemon) container
		image_test_service ;;

	image:test-service-run) ## %% 🏗  Start a service (daemon) container for testing
		image_test_service_run ;;

	image:test-service-inspect) ## %% 🏗  Inspect a service (daemon) container for testing
		image_test_service_inspect ;;

	image:test-service-remove) ## %% 🏗  Remove the service (daemon) container for testing
		image_test_service_remove ;;

	image:test-cli) ## %% 🏗  Test a command-line container
		image_test_service ;;

	image:clean) ## %% 🗑  Remove all Docker images related to your project
		image_clean ;;

	image:tag) ## %% 🏷  Tag the Docker image for your project
		image_tag ;;

	image:upload) ## [<image name>] %% ⬆️  Upload your project's Docker image to your registry
		image_upload ${args} ;;

	image:version) ## %% ⬆️  Reflect the wrapped software's version
		image_version ;;

	image:build-version-upload) ## %% ⬆️  Build and Upload multiple tagged Docker images to your registry
		image_build_version_upload ;;

	*)
		module_help
esac