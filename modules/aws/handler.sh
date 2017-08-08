#!/usr/bin/env bash

case "${command:-}" in
	aws) ## [options] <command> <subcommand> [<subcommand> ...] [parameters] %% AWS CLI
		aws_cli "${args}" ;;
esac
