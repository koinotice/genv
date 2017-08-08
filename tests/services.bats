#!/usr/bin/env bats

setup() {
	load helper
}

@test "service exists" {
	set_harpoon_roots
	harpoon_load services/services.sh
	service_exists mysql
	[ $? -eq 0 ]
	[ "${SERVICE_ROOT}" != "" ]
}

@test "mysql help" {
	run ./harpoon mysql:help
	[ "$status" -eq 0 ]
	grep "MySQL Client" <<< "$output"
}