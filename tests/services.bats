#!/usr/bin/env bats

setup() {
	load helper
}

@test "service exists" {
	setHarpoonRoots
	harpoonLoad services/services.sh
	serviceExists mysql
	[ $? -eq 0 ]
	[ "${SERVICE_ROOT}" != "" ]
}

@test "mysql help" {
	run ./harpoon mysql:help
	[ "$status" -eq 0 ]
	grep "MySQL Client" <<< "$output"
}

@test "mysql status - up" {
	export HARPOON_USE_EMOJI=false
	run ./harpoon mysql:up
	run ./harpoon mysql:status
	[ "$status" -eq 0 ]
	egrep "mysql\s+Up" <<< "$output"
	run ./harpoon services:status
	egrep "mysql\s+Up" <<< "$output"
}

@test "mysql status - down" {
	export HARPOON_USE_EMOJI=false
	run ./harpoon mysql:destroy
	run ./harpoon mysql:status
	[ "$status" -eq 1 ]
	egrep "mysql\s+Down" <<< "$output"
	run ./harpoon services:status
	egrep "mysql\s+Down" <<< "$output"
}