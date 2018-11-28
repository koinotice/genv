#!/usr/bin/env bash

case "${command}" in
	{{NAME}}) ## {{ARGS}} %% {{DESCRIPTION}}
        genv_{{NAME}}CLI "${args}" ;;
esac
