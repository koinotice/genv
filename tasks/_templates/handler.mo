#!/usr/bin/env bash

case "${command:-}" in
	{{NAME}}) ## {{ARGS}} %% {{DESCRIPTION}}
        harpoon_{{NAME}}_cli "${args}" ;;
esac
