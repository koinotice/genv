#!/usr/bin/env bash

case "${command}" in
	{{NAME}}) ## {{ARGS}} %% {{DESCRIPTION}}
        harpoon_{{NAME}}CLI "${args}" ;;
esac
