#!/usr/bin/env bash

case "${command}" in
	redis:cli) ## [<arg>...] %% Redis CLI
		$(serviceDockerComposeExec redis) redis redis-cli ${args} ;;
	*)
		serviceHelp redis
esac
