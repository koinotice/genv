#!/usr/bin/env bash

# $1 command
parse_module() {
	echo ${1:-} | cut -d ':' -f 1
}

# $1 command
parse_subcmd() {
	echo ${1:-} | cut -d ':' -f 2
}