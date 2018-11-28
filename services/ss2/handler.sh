#!/usr/bin/env bash

case "${command}" in
	redis:cli) ## [<arg>...] %% Redis CLI
		$(serviceDockerComposeExec ss2) redis redis-cli ${args} ;;
	*)
		serviceHelp redis
esac
