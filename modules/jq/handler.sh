#!/usr/bin/env bash


case "${command:-}" in
	jq) ## [options] <jq filter> [file...] %% A lightweight and flexible command-line JSON processor
		jq_cli "${args}" ;;
esac
