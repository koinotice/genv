#!/usr/bin/env bash

parse_cmd() {
	echo ${1:-} | awk 'match($0, /[a-zA-Z0-9_-]+/) {print substr($0, RSTART, RLENGTH)}'
}
