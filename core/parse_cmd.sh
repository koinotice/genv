#!/usr/bin/env bash

parse_cmd() {
	echo ${1:-} | awk 'match($0, /[a-z_-]+/) {print substr($0, RSTART, RLENGTH)}'
}