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

@test "cadvisor status - up" {
	export HARPOON_USE_EMOJI=false
	run ./harpoon cadvisor:up
	[ "$status" -eq 0 ]
	run ./harpoon cadvisor:status
	[ "$status" -eq 0 ]
	egrep "cadvisor\s+Up" <<< "$output"
	run ./harpoon services:status
	[ "$status" -eq 0 ]
	egrep "cadvisor\s+Up" <<< "$output"
}

@test "cadvisor status - down" {
	export HARPOON_USE_EMOJI=false
	run ./harpoon cadvisor:destroy
	[ "$status" -eq 0 ]
	run ./harpoon cadvisor:status
	[ "$status" -eq 1 ]
	egrep "cadvisor\s+Down" <<< "$output"
	run ./harpoon services:status
	[ "$status" -eq 0 ]
	egrep "cadvisor\s+Down" <<< "$output"
}

@test "multiple status - up" {
	export HARPOON_USE_EMOJI=false
	run ./harpoon service up portainer mailhog
	[ "$status" -eq 0 ]
	run ./harpoon service status portainer
	[ "$status" -eq 0 ]
	egrep "portainer\s+Up" <<< "$output"
	run ./harpoon service status mailhog
	[ "$status" -eq 0 ]
	egrep "mailhog\s+Up" <<< "$output"
	run ./harpoon service status portainer mailhog
	[ "$status" -eq 0 ]
	egrep "portainer\s+Up" <<< "$output"
	egrep "mailhog\s+Up" <<< "$output"
}

@test "multiple status - down" {
	export HARPOON_USE_EMOJI=false
	run ./harpoon service down portainer mailhog
	[ "$status" -eq 0 ]
	run ./harpoon service status portainer
	[ "$status" -eq 0 ]
	egrep "portainer\s+Down" <<< "$output"
	run ./harpoon service status mailhog
	[ "$status" -eq 0 ]
	egrep "mailhog\s+Down" <<< "$output"
	run ./harpoon service status portainer mailhog
	[ "$status" -eq 0 ]
	egrep "portainer\s+Down" <<< "$output"
	egrep "mailhog\s+Down" <<< "$output"
}