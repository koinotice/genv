#!/usr/bin/env bash


case "${command:-}" in
	jp) ## [<options>] <expression> %% JMESPath tool
		jp_cli "${args}" ;;
esac
