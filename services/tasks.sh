#!/usr/bin/env bash

case "${first_arg}" in
	ls|list)
		services ;;

	help)
		print_service_help "<service-name>" ;;

	*)
		name=${2:-}
		service_exists ${name}

		command="${name}:${3:-}"
		args=${@:4}

		handle_service ${name} ${command}
esac

