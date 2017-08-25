#!/usr/bin/env bash

case "${firstArg}" in
	ls|list)
		listServices ;;

	help)
		printServiceHelp "<service-name>" ;;

	*)
		name=${2:-}
		serviceExists ${name}

		command="${name}:${3:-}"
		args=${@:4}

		handleService ${name} ${command}
esac

