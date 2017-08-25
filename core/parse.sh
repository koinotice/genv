#!/usr/bin/env bash

# $1 command
parseModule() {
	echo ${1:-} | cut -d ':' -f 1
}

# $1 command
parseSubCmd() {
	echo ${1:-} | cut -d ':' -f 2
}