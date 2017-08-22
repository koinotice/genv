#!/usr/bin/env bash

case "${command}" in
	http) ## <arg...> %% 🌎  HTTPie
		httpie "${args}" ;;

	http:noinput) ## <arg...> %% 🌎  HTTPie (no STDIN)
		httpie_no_input "${args}" ;;

	*)
		task_help
esac