#!/usr/bin/env bash

set -euo pipefail

command=${1:-}
args=${@:2}

export DSOCK=/var/run/docker.sock

case "${command}" in
	push)
		docker tag harpoon ${TAG}
		docker push ${TAG}
		if [[ "${REF}" == 'master' ]]; then
			docker tag harpoon "${REPOSITORY}:latest"
			docker push "${REPOSITORY}:latest"
		fi
		;;

	test)
		rm -fr _kcov
		docker pull wheniwork/dind-kcov-bats
		docker run --rm -v ${DSOCK}:${DSOCK} -v $PWD:/src wheniwork/dind-kcov-bats bash -c "kcov --coveralls-id ${TRAVIS_JOB_ID} --include-path=/src --exclude-path=/src/tests _kcov bats tests"
		bash <(curl -s https://codecov.io/bash) -s _kcov
		;;

	test:dind)
		rm -fr _kcov
		docker pull wheniwork/dind-kcov-bats
		docker run --privileged -d -v $PWD:/src --name dind-kcov-bats wheniwork/dind-kcov-bats --storage-driver=overlay2
		docker exec dind-kcov-bats bash -c "kcov --coveralls-id ${TRAVIS_JOB_ID} --include-path=/src --exclude-path=/src/tests --exclude-path=/src/lib _kcov bats tests"
		bash <(curl -s https://codecov.io/bash) -s _kcov
		;;

	test:local)
		rm -fr _kcov
		docker pull wheniwork/dind-kcov-bats
		docker run --privileged -d -v $PWD:/src --name dind-kcov-bats wheniwork/dind-kcov-bats --storage-driver=overlay2
		docker exec dind-kcov-bats bash -c "kcov --include-path=/src --exclude-path=/src/tests --exclude-path=/src/lib _kcov bats tests"
		docker rm -f dind-kcov-bats
esac